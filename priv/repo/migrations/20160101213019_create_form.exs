defmodule Exon.Repo.Migrations.CreateForm do
  use Ecto.Migration

  def change do
    create table(:forms) do

      timestamps
    end

  end
end
