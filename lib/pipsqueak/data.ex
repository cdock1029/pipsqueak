defmodule Pipsqueak.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Pipsqueak.Repo

  alias Pipsqueak.Data.Node

  @doc """
  Returns the list of nodes.

  ## Examples

      iex> list_nodes()
      [%Node{}, ...]

  """
  def list_nodes do
    Repo.all(Node) |> Repo.preload([:parent, :children])
  end

  @doc """
  Gets a single node.

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

      iex> get_node!(123)
      %Node{}

      iex> get_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_node!(id) when not is_nil(id) do
    query =
      from n in Node,
        left_join: c in assoc(n, :children),
        preload: [children: c]

    Repo.get!(query, id)
  end

  def get_node!(nil) do
    from(n in Node,
      left_join: c in assoc(n, :children),
      where: is_nil(n.parent_id),
      preload: [children: c]
    )
    |> Repo.all()
    |> hd()
  end

  def get_graph(id) do
    node_graph_initial_query =
      case id do
        nil -> from(n in Node, where: is_nil(n.parent_id))
        node_id -> from(n in Node, where: n.id == ^node_id)
      end

    node_graph_recursion_query =
      from n in Node, inner_join: ng in "node_graph", on: n.parent_id == ng.id

    node_graph_query = node_graph_initial_query |> union(^node_graph_recursion_query)

    nodes =
      {"node_graph", Node}
      |> recursive_ctes(true)
      |> with_cte("node_graph", as: ^node_graph_query)
      |> Repo.all()

    build_tree(nodes)
  end

  defp build_tree([]), do: nil
  defp build_tree([root]), do: %Node{root | children: []}

  defp build_tree([root | nodes]) do
    groups = Enum.group_by(nodes, & &1.parent_id)
    associate_children(root, groups)
  end

  defp associate_children(node, groups) do
    children_trees =
      groups
      |> Map.get(node.id, [])
      |> Stream.map(&%Node{&1 | __meta__: %{&1.__meta__ | source: "nodes"}})
      |> Enum.map(&associate_children(&1, groups))

    Map.put(node, :children, children_trees)
  end

  @doc """
  Creates a node.

  ## Examples

      iex> create_node(%{field: value})
      {:ok, %Node{}}

      iex> create_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_node(attrs \\ %{}) do
    %Node{} |> Node.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Updates a node.

  ## Examples

      iex> update_node(node, %{field: new_value})
      {:ok, %Node{}}

      iex> update_node(node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_node(%Node{} = node, attrs) do
    case change_node(node, attrs) do
      %Ecto.Changeset{changes: %{} = changes} when map_size(changes) == 0 ->
        {:ok, :nochanges}

      changeset ->
        Repo.update(changeset)
    end
  end

  @doc """
  Deletes a node.

  ## Examples

      iex> delete_node(node)
      {:ok, %Node{}}

      iex> delete_node(node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_node(%Node{} = node) do
    Repo.delete(node)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking node changes.

  ## Examples

      iex> change_node(node)
      %Ecto.Changeset{data: %Node{}}

  """
  def change_node(%Node{} = node, attrs \\ %{}) do
    Node.changeset(node, attrs)
  end

  def update_node_expanded(%Node{} = node, updated_exanded_value) do
    changeset = change_node(node, %{expanded: updated_exanded_value})
    Repo.update(changeset)
  end

  def update_all_expanded(value) do
    from(Node, update: [set: [expanded: ^value]])
    |> Repo.update_all([])
  end
end
