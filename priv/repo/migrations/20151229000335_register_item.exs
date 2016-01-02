defmodule Exon.Repo.Migrations.RegisterItem do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      timestamps
    end
  end
end
