defmodule Exon.Content.Item do
  use Ecto.Schema
  import Ecto.Changeset, except: [timestamps: 0]
  alias Exon.Accounts.User
  alias __MODULE__


  schema "items" do
    field :comments, :string, null: false
    field :name, :string, [default: "", null: false]
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, [:name, :comments])
    |> validate_required([:name, :comments])
    |> validate_length(:name, min: 3)
  end
end
