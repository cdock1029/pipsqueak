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
    <div>
      <div phx-click={JS.navigate(~p"/?n=#{@node.id}")} class="flex items-center space-x-8">
        <div class="py-4 cursor-pointer">
          <button phx-click="toggle-expanded" phx-target={@myself}>
            <.icon
              name={(@node.expanded && "hero-plus-circle-solid") || "hero-plus-circle"}
              class="w-5 h-5"
            />
          </button>
        </div>
        <div class="py-4 cursor-pointer"><%= @node.id %></div>
        <div class="py-4 cursor-pointer"><%= @node.title %></div>
        <div class="py-4 cursor-pointer"><%= @node.description %></div>
      </div>
      <div :if={@node.expanded} class="ml-10">
        <.live_component :for={child <- @children} module={__MODULE__} id={child.id} node={child} />
      </div>
    </div>

    <%!-- <.table id="nodes" rows={@children} row_click={fn node -> JS.navigate(~p"/?n=#{node.id}") end}>
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
    </.table> --%>
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
    """
  end
end
