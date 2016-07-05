defmodule Exon.User do
  use Ecto.Model

  schema "users" do
    field :username, :string
    field :hashed_password, :string
    timestamps
  end

end
