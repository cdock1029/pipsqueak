defmodule PipsqueakWeb.NodeHelpers do
  use PipsqueakWeb, :component

  def title(assigns) do
    ~H"""
    <.header header_id="page-heading" class={[@node.title == "ROOT" && "invisible", "mb-8"]}>
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
