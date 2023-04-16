defmodule PipsqueakWeb.NodeComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data
  alias PipsqueakWeb.NodeTitleComponent

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
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
        <div class="flex-1">
          <.live_component module={NodeTitleComponent} node={@node} id={"node-title-#{@node.id}"} />
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

    if node.expanded do
      assign(socket, :children, Pipsqueak.Repo.preload(node, :children).children)
      # assign_new(socket, :children, fn ->
      #   Pipsqueak.Repo.preload(node, :children).children
      # end)
    else
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

defmodule PipsqueakWeb.NodeTitleComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:editing, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p :if={!@editing} phx-click={JS.push("enable-editing", target: @myself)}><%= @node.title %></p>
      <.node_form
        :if={@editing}
        for={@form}
        id={"node-title-form-#{@node.id}"}
        phx-target={@myself}
        phx-submit="save-and-disable-editing"
      >
        <.node_input
          field={@form[:title]}
          class="px-0 py-0 text-green-400 border-none sm:text-base"
          phx-click-away={JS.dispatch("submit", to: "#node-title-form-#{@node.id}")}
        />
      </.node_form>
    </div>
    """
  end

  @impl true
  def handle_event("enable-editing", _params, socket) do
    changeset = Data.change_node(socket.assigns.node)
    {:noreply, socket |> assign(:editing, true) |> assign_form(changeset)}
  end

  def handle_event("save-and-disable-editing", %{"node" => node_params}, socket) do
    case Data.update_node(socket.assigns.node, node_params) do
      {:ok, :nochanges} ->
        {:noreply, assign(socket, :editing, false)}

      {:ok, node} ->
        send(self(), {__MODULE__, :updated})

        {:noreply,
         socket
         |> assign(:node, node)
         |> assign(:editing, false)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("title_change", _params, socket) do
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
