defmodule Pipsqueak.Data.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :description, :string
    field :expanded, :boolean, default: false
    field :title, :string
    belongs_to :parent, __MODULE__

    has_many :children, __MODULE__

    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :expanded])
    |> validate_required([:title])
    |> cast_assoc(:children)
  end
end
