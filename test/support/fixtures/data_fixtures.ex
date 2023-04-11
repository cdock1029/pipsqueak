defmodule Pipsqueak.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pipsqueak.Data` context.
  """

  @doc """
  Generate a node.
  """
  def node_fixture(attrs \\ %{}) do
    {:ok, node} =
      attrs
      |> Enum.into(%{
        description: "some description",
        expanded: true,
        title: "some title"
      })
      |> Pipsqueak.Data.create_node()

    node
  end
end
