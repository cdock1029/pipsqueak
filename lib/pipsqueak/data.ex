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
  def get_node!(id) when not is_nil(id),
    do: Repo.get!(Node, id) |> Repo.preload([:parent, :children])

  def get_node!(nil) do
    q =
      from n in Node,
        where: is_nil(n.parent_id)

    [node] = Repo.all(q) |> Repo.preload([:parent, :children])
    node
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
    # q =
    #   from n in Node,
    #     where: [id: ^node.id],
    #     update: [set: [expanded: not n.expanded]]

    # Repo.update_all(q, [])
  end
end
