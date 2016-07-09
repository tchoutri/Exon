defmodule Exon.User do
  use Ecto.Model

  schema "users" do
    field :username, :string
    field :hashed_password, :string
    timestamps
  end

  @required_fields ["username", "hashed_password"]
  @optional_fields ~w()

   def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields, @optional_fields)
  end
end
