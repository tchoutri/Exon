defmodule Exon.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :comments, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
