defmodule Exon.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string

      timestamps
    end
  end
end
