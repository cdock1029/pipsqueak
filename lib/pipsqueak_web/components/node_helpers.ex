defmodule PipsqueakWeb.NodeHelpers do
  use PipsqueakWeb, :component

  def title(assigns) do
    ~H"""
    <.header header_id="page-heading" class={[@node.title == "ROOT" && "hidden", "mb-4 ml-12"]}>
      <div class="flex space-x-6">
        <h1 class="text-xl font-semibold">
          <%= @node.title %>
        </h1>
      </div>
      <:subtitle>
        <%= @node.description %>
      </:subtitle>
    </.header>
    """
  end
end
