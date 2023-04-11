defmodule PipsqueakWeb.HomeLive.Index do
  use PipsqueakWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>Home</.header>
    <div class="mt-11">
      <p>Todo</p>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Home")

    # |> assign(:node, nil)
  end
end
