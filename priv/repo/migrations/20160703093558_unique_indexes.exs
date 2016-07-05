defmodule Exon.Repo.Migrations.UniqueIndexes do
  use Ecto.Migration

  def change do
    create index(:users, [:username], unique: true)
    create index(:items, [:name], unique: true)
  end
end
