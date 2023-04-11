defmodule Pipsqueak.Data.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :description, :string
    field :expanded, :boolean, default: false
    field :title, :string
    belongs_to :parent, __MODULE__, foreign_key: :parent_id

    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :expanded, :parent_id])
    |> validate_required([:title])
    |> validate_parent_not_self()
    |> cast_assoc(:children)
  end

  def validate_parent_not_self(changeset) do
    if get_field(changeset, :parent_id) == get_field(changeset, :id) do
      add_error(changeset, :parent_id, "Cannot set parent = self.")
    else
      changeset
    end
  end
end
