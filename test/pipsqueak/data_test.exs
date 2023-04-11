defmodule Pipsqueak.DataTest do
  use Pipsqueak.DataCase

  alias Pipsqueak.Data

  describe "nodes" do
    alias Pipsqueak.Data.Node

    import Pipsqueak.DataFixtures

    @invalid_attrs %{description: nil, expanded: nil, title: nil}

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Data.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Data.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      valid_attrs = %{description: "some description", expanded: true, title: "some title"}

      assert {:ok, %Node{} = node} = Data.create_node(valid_attrs)
      assert node.description == "some description"
      assert node.expanded == true
      assert node.title == "some title"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      update_attrs = %{description: "some updated description", expanded: false, title: "some updated title"}

      assert {:ok, %Node{} = node} = Data.update_node(node, update_attrs)
      assert node.description == "some updated description"
      assert node.expanded == false
      assert node.title == "some updated title"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_node(node, @invalid_attrs)
      assert node == Data.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Data.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Data.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Data.change_node(node)
    end
  end
end
