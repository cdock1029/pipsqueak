defmodule PipsqueakWeb.HomeLive.Index do
  use PipsqueakWeb, :live_view

  alias Pipsqueak.Data
  alias Pipsqueak.Data.Node

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header class={[@node.title == "ROOT" && "invisible"]}>
      <%= @node.title %>
      <:subtitle>
        <%= if @node.title == "ROOT" do %>
          <span>
            <%= @node.description %>
          </span>
        <% else %>
          <span>
            <%= @node.description %>
          </span>
        <% end %>
      </:subtitle>
    </.header>
    <.table id="nodes" rows={@children} row_click={fn node -> JS.navigate(~p"/?n=#{node.id}") end}>
      <:col :let={node} label="ID"><%= node.id %></:col>
      <:col :let={node} label="Title"><%= node.title %></:col>
      <:col :let={node} label="Description"><%= node.description %></:col>
      <:col :let={node} label="Expanded">
        <button phx-click="toggle-expanded" value={node.id}>
          <.icon
            name={(node.expanded && "hero-plus-circle-solid") || "hero-plus-circle"}
            class="w-5 h-5"
          />
        </button>
      </:col>
    </.table>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("toggle-expanded", %{"value" => id}, socket) do
    result = Data.toggle_node_expanded(%Node{id: id})
    IO.inspect(result, label: "result")
    # children = socket.assigns.children
    # index = Enum.find_index(children, &(&1.id |> to_string == id))

    # List.update_at()

    {:noreply, socket}
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
end
