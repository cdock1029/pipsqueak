defmodule PipsqueakWeb.HomeLive.Index do
  use PipsqueakWeb, :live_view

  alias PipsqueakWeb.NodeComponent
  alias Pipsqueak.Data
  alias Pipsqueak.Data.Node
  alias PipsqueakWeb.NodeHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <NodeHelpers.title node={@node} />
    <.live_component :for={node <- @children} module={NodeComponent} id={node.id} node={node} />
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"n" => node_id}) do
    socket
    |> assign(:page_title, "Node:#{node_id}")
    |> assign_nodes(node_id)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Home")
    |> assign_nodes(nil)
  end

  defp assign_nodes(socket, node_id) do
    node = Data.get_node!(node_id)

    socket |> assign(:node, node) |> assign(:children, node.children)
  end

  @impl true
  def handle_info({PipsqueakWeb.NodeTitleComponent, :updated}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Node updated successfully")
     |> assign_nodes(socket.assigns.node.id)}
  end
end
