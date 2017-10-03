defmodule Exon.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset, except: [timestamps: 0]
  alias __MODULE__


  schema "users" do
    field :password_hash, :string
    field :password, :string, virtual: true
    field :username, :string
    has_many :items, Exon.Content.Item

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_length(:username, min: 1, max: 30)
    |> unique_constraint(:username)
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> put_pass_hash()
  end

  def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}}=changeset) do
    change(changeset, Comeonin.Argon2.add_hash(pass))
  end
  def put_pass_hash(changeset), do: changeset
end
