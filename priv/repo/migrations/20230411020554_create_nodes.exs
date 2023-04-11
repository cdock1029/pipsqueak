defmodule Pipsqueak.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :title, :string
      add :description, :text
      add :expanded, :boolean, default: false, null: false
      add :parent_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:nodes, [:parent_id])
  end
end
