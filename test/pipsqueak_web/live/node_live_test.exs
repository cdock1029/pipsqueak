defmodule PipsqueakWeb.NodeLiveTest do
  use PipsqueakWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pipsqueak.DataFixtures

  @create_attrs %{description: "some description", expanded: true, title: "some title"}
  @update_attrs %{description: "some updated description", expanded: false, title: "some updated title"}
  @invalid_attrs %{description: nil, expanded: false, title: nil}

  defp create_node(_) do
    node = node_fixture()
    %{node: node}
  end

  describe "Index" do
    setup [:create_node]

    test "lists all nodes", %{conn: conn, node: node} do
      {:ok, _index_live, html} = live(conn, ~p"/nodes")

      assert html =~ "Listing Nodes"
      assert html =~ node.description
    end

    test "saves new node", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/nodes")

      assert index_live |> element("a", "New Node") |> render_click() =~
               "New Node"

      assert_patch(index_live, ~p"/nodes/new")

      assert index_live
             |> form("#node-form", node: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#node-form", node: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/nodes")

      html = render(index_live)
      assert html =~ "Node created successfully"
      assert html =~ "some description"
    end

    test "updates node in listing", %{conn: conn, node: node} do
      {:ok, index_live, _html} = live(conn, ~p"/nodes")

      assert index_live |> element("#nodes-#{node.id} a", "Edit") |> render_click() =~
               "Edit Node"

      assert_patch(index_live, ~p"/nodes/#{node}/edit")

      assert index_live
             |> form("#node-form", node: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#node-form", node: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/nodes")

      html = render(index_live)
      assert html =~ "Node updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes node in listing", %{conn: conn, node: node} do
      {:ok, index_live, _html} = live(conn, ~p"/nodes")

      assert index_live |> element("#nodes-#{node.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#nodes-#{node.id}")
    end
  end

  describe "Show" do
    setup [:create_node]

    test "displays node", %{conn: conn, node: node} do
      {:ok, _show_live, html} = live(conn, ~p"/nodes/#{node}")

      assert html =~ "Show Node"
      assert html =~ node.description
    end

    test "updates node within modal", %{conn: conn, node: node} do
      {:ok, show_live, _html} = live(conn, ~p"/nodes/#{node}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Node"

      assert_patch(show_live, ~p"/nodes/#{node}/show/edit")

      assert show_live
             |> form("#node-form", node: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#node-form", node: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/nodes/#{node}")

      html = render(show_live)
      assert html =~ "Node updated successfully"
      assert html =~ "some updated description"
    end
  end
end
