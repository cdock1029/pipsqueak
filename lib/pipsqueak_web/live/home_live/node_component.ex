defmodule PipsqueakWeb.NodeComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data
  alias PipsqueakWeb.NodeTitleComponent

  alias Pipsqueak.Data.Node

  @impl true
  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    childrens = Data.get_children_from_ids(list_of_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :children, Map.get(childrens, assigns.id, []))
    end)
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: {:update_expand, expand_value}}, socket) do
    Enum.each(socket.assigns.children, fn child ->
      send_update(PipsqueakWeb.NodeComponent, id: child.id, action: {:update_expand, expand_value})
    end)

    {:ok,
     update(socket, :node, fn node ->
       %Node{node | expanded: expand_value}
     end)}
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
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
      <div class={[!@node.expanded && "hidden", "pl-16 mb-2 ml-2 child-nodes border-l-2"]}>
        <.live_component :for={child <- @children} module={__MODULE__} id={child.id} node={child} />
        <p :if={length(@children) == 0} class="pb-4 text-sm text-gray-600">
          empty
        </p>
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
          class="px-0 py-0 text-base !text-green-500 !font-semibold border-none"
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
        # send(self(), {__MODULE__, :updated})
        send_update(PipsqueakWeb.NodeComponent, id: node.id, node: node)

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
