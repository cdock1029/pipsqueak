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
    <p :if={length(@children) == 0} class="py-4 text-sm text-gray-600">
      empty
    </p>
    <.live_component :for={node <- @children} module={NodeComponent} id={node.id} node={node} />
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

  def handle_info({:squeak, id}, socket) do
    IO.inspect(id, label: "got squeak:")
    {:noreply, socket}
  end
end
