defmodule PipsqueakWeb.NodeComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data
  alias PipsqueakWeb.NodeTitleComponent

  alias Pipsqueak.Data.Node

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:children, assigns.node.children)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="node-component">
      <div class="flex items-start mb-4 node-main-content">
        <div class="flex items-start space-x-3 controls">
          <button
            phx-click="toggle-expanded"
            phx-target={@myself}
            class={[length(@children) == 0 && "invisible"]}
          >
            <.icon
              name={(@node.expanded && "hero-chevron-down") || "hero-chevron-right"}
              class="w-3 h-3"
            />
          </button>
          <.link patch={~p"/?n=#{@node.id}"}>
            <.icon name="hero-link" class="w-3 h-3" />
          </.link>
        </div>
        <div class="flex-1 ml-4">
          <.live_component module={NodeTitleComponent} node={@node} id={"node-title-#{@node.id}"} />
          <p :if={@node.description} class="mt-2 text-xs text-gray-600"><%= @node.description %></p>
        </div>
      </div>
      <div
        id={"list-wrapper-#{@node.id}"}
        class={[
          (!@node.expanded or length(@children) == 0) && "hidden",
          "pl-8 mb-2 ml-1 child-nodes border-l-2"
        ]}
      >
        <.live_component :for={child <- @children} module={__MODULE__} id={child.id} node={child} />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle-expanded", _params, socket) do
    {:noreply,
     update(socket, :node, fn node ->
       Task.start(fn ->
         Data.update_node_expanded(node, !node.expanded)
       end)

       %Node{node | expanded: !node.expanded}
     end)}
  end
end

defmodule PipsqueakWeb.NodeTitleComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data

  @impl true
  def update(assigns, socket) do
    changeset = Data.change_node(assigns.node)
    {:ok, socket |> assign(assigns) |> assign_form(changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.node_form
        for={@form}
        id={"node-title-form-#{@node.id}"}
        phx-target={@myself}
        phx-change="save"
        phx-submit="add_new"
      >
        <.node_input
          id={"node-title-input-#{@node.id}"}
          field={@form[:title]}
          phx-debounce="500"
          class="px-0 py-0 text-base border-none"
        />
      </.node_form>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"node" => node_params}, socket) do
    case Data.update_node(socket.assigns.node, node_params) do
      {:ok, :nochanges} ->
        {:noreply, socket}

      {:ok, node} ->
        send_update(PipsqueakWeb.NodeComponent, id: node.id, node: node)

        {:noreply, socket |> assign(:node, node)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("add_new", params, socket) do
    node = socket.assigns.node
    IO.inspect({params, node}, label: "add-new params")
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
