defmodule PipsqueakWeb.HomeLive.Index do
  use PipsqueakWeb, :live_view

  alias PipsqueakWeb.NodeComponent
  alias Pipsqueak.Data
  alias PipsqueakWeb.NodeHelpers

  @topic inspect(__MODULE__)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Pipsqueak.PubSub, @topic)
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <NodeHelpers.title node={@node} />
    <.live_component
      :for={node <- @children}
      :if={@node}
      module={NodeComponent}
      id={node.id}
      node={node}
    />
    <section class="absolute flex items-center space-x-8 top-8 right-12">
      <.button class="bg-purple-700" phx-click="expand-all">Expand all</.button>
      <.button phx-click="collapse-all">Collapse all</.button>
    </section>
    """
  end

  @impl true
  def handle_params(%{"n" => node_id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Node:#{node_id}")
     |> assign_nodes(node_id)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Home")
     |> assign_nodes(nil)}
  end

  @impl true
  def handle_info({PipsqueakWeb.NodeTitleComponent, :updated}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Node updated successfully")
     |> assign_nodes(socket.assigns.node.id)}
  end

  def handle_info({:squeak, id}, socket) do
    IO.inspect(id, label: "got squeak:")
    {:noreply, socket}
  end

  @impl true
  def handle_event("expand-all", _params, socket), do: execute_expand_op(true, socket)

  def handle_event("collapse-all", _params, socket), do: execute_expand_op(false, socket)

  defp assign_nodes(socket, node_id) do
    node = Data.get_graph(node_id)
    socket |> assign(node: node, children: (node && node.children) || [])
  end

  defp execute_expand_op(value, socket) do
    Data.update_all_expanded(value)
    {:noreply, assign_nodes(socket, socket.assigns.node.id)}
  end
end
