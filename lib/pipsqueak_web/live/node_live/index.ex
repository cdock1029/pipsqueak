defmodule PipsqueakWeb.NodeLive.Index do
  use PipsqueakWeb, :live_view

  alias Pipsqueak.Data
  alias Pipsqueak.Data.Node

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :nodes, Data.list_nodes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Node")
    |> assign(:node, Data.get_node!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Node")
    |> assign(:node, %Node{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Nodes")
    |> assign(:node, nil)
  end

  @impl true
  def handle_info({PipsqueakWeb.NodeLive.FormComponent, {:saved, node}}, socket) do
    {:noreply, stream_insert(socket, :nodes, node)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    node = Data.get_node!(id)
    {:ok, _} = Data.delete_node(node)

    {:noreply, stream_delete(socket, :nodes, node)}
  end
end
