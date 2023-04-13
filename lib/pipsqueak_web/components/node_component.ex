defmodule PipsqueakWeb.NodeComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data

  @impl true
  def update(assigns, socket) do
    IO.inspect("update node-#{assigns.node.id}")

    {:ok,
     socket
     |> assign(assigns)
     # |> assign(:expanded, assigns.node.expanded)
     |> maybe_assign_children()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="node-component">
      <div class="flex items-start mb-4 space-x-6 node-main-content">
        <div class="flex items-start space-x-4 controls">
          <button phx-click="toggle-expanded" phx-target={@myself}>
            <.icon
              name={(@node.expanded && "hero-chevron-down") || "hero-chevron-right"}
              class="w-4 h-4"
            />
          </button>
          <.link patch={~p"/?n=#{@node.id}"}>
            <.icon name="hero-link" class="w-4 h-4" />
          </.link>
        </div>
        <div><%= @node.id %></div>
        <div>
          <p><%= @node.title %></p>
          <p :if={@node.description} class="mt-2 text-xs text-gray-600"><%= @node.description %></p>
        </div>
      </div>
      <div :if={@node.expanded} class="ml-16 child-nodes">
        <.live_component :for={child <- @children} module={__MODULE__} id={child.id} node={child} />
        <p :if={length(@children) == 0} class="py-4 text-sm text-gray-600">
          empty
        </p>
      </div>
    </div>
    """
  end

  def maybe_assign_children(socket) do
    node = socket.assigns.node
    IO.puts("maybe_assign_children ID:#{node.id}")

    if node.expanded do
      IO.puts("node expanded..")

      assign_new(socket, :children, fn ->
        IO.puts("..loading children")
        Pipsqueak.Repo.preload(node, :children).children
      end)
    else
      IO.puts("not expanded")
      socket
    end
  end

  @impl true
  def handle_event("toggle-expanded", _params, socket) do
    updated_expanded_value = !socket.assigns.node.expanded
    {:ok, node} = Data.update_node_expanded(socket.assigns.node, updated_expanded_value)
    {:noreply, socket |> assign(:node, node) |> maybe_assign_children()}
  end
end

defmodule PipsqueakWeb.NodeHelpers do
  use PipsqueakWeb, :component

  def title(assigns) do
    ~H"""
    <.header class={[@node.title == "ROOT" && "invisible", "mb-8"]}>
      <div class="flex space-x-6">
        <p>
          <%= @node.id %>
        </p>
        <p>
          <%= @node.title %>
        </p>
      </div>
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
    """
  end
end
