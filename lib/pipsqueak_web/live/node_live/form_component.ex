defmodule PipsqueakWeb.NodeLive.FormComponent do
  use PipsqueakWeb, :live_component

  alias Pipsqueak.Data

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:nodes, Data.list_nodes())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage node records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="node-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          field={@form[:parent_id]}
          type="select"
          label="Parent"
          prompt="Choose parent node"
          options={Enum.map(@nodes, &{&1.title, &1.id})}
        />
        <.input field={@form[:expanded]} type="checkbox" label="Expanded" />
        <:actions>
          <.button
            disabled={!@form.source.valid?}
            phx-disable-with="Saving..."
            class="disabled:cursor-not-allowed"
          >
            Save Node
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{node: node} = assigns, socket) do
    changeset = Data.change_node(node)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"node" => node_params}, socket) do
    changeset =
      socket.assigns.node
      |> Data.change_node(node_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"node" => node_params}, socket) do
    save_node(socket, socket.assigns.action, node_params)
  end

  defp save_node(socket, :edit, node_params) do
    case Data.update_node(socket.assigns.node, node_params) do
      {:ok, node} ->
        notify_parent({:saved, node})

        {:noreply,
         socket
         |> put_flash(:info, "Node updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_node(socket, :new, node_params) do
    case Data.create_node(node_params) do
      {:ok, node} ->
        notify_parent({:saved, node})

        {:noreply,
         socket
         |> put_flash(:info, "Node created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset) |> IO.inspect())
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
