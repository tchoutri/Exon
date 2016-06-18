defmodule Exon.Item do
@moduledoc false
  use Ecto.Model

  schema "items" do
    field :name, :string
    field :comments, :string, [default: "", null: false]
    timestamps
  end

  def changeset(note, params \\ :empty) do
    cast(note, params, ~w(), ~w(comments))
  end

end
