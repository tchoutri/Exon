defmodule Exon.Repo.Migrations.ItemComments do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :comments, :string, [default: "", null: false]
    end
  end
end
