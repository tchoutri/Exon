defmodule Exon.Database do
  @moduledoc false

  use GenServer
  require Logger
  alias Exon.Accounts.User
  alias Exon.Content.Item
  alias Exon.Repo
  alias Exon.Structs.{Message, Info, Client}
  import Ecto.Query

  @spec get_id(String.t) :: {:ok, %Item{}} | {:not_found, integer()}
  def get_id(id) do
    with {:ok, int_id} <- process_id(id),
         {:ok, item}   <- get_id_informations(int_id) do
           parse_information {:ok, item}
    else
      err -> parse_information(err)
    end
  end

  @spec add_new_item(String.t, String.t, %Client{}) :: {:ok, integer()} | {:duplicate, integer()}
  def add_new_item(name, comments, client) do
    name
    |> String.trim
    |> String.downcase
    |> String.capitalize
    |> check_duplicate
    |> record(comments, client.username)

  end

  @spec add_new_comment(integer(), String.t) :: {:ok, :added} | {:error, String.t}
  def add_new_comment(id, comments) do
    query = from i in Item, where: i.id == ^id, select: i

    with item =  hd(Repo.all query),
         comments <-  item.comments <> "\n" <> comments,
         {:ok, _} = Repo.update Item.changeset(item, %{comments: comments}) do
           {:ok, :added}
    else
        []          -> {:error, "Item does not exist"}
        {:error, _} -> {:error, "Could not register comment into the database"}
    end
  end

  def add_new_user(username, password) do
    result = case NotQwerty123.PasswordStrength.strong_password?(password) do
      {:ok, ^password} ->
        Logger.debug("Password strong enough")

        %User{}
        |> User.registration_changeset(%{username: username, password: password})
        |> Repo.insert!

        Logger.debug("User #{username} registered!")
        {:ok, :registered}

      error_msg ->
        Logger.warn(error_msg)
        {:error, :weak_password}
    end
  end

  def del_item(id) do
    id = String.to_integer(id)
    case Repo.get(Item, id) do
      nil ->
        Logger.warn "No item with id " <> id
        {:error, :notfound}
      item ->
        Repo.delete(item) && {:ok, :deleted}
    end
  end

  def del_user(username) do
    query = from user in User, where: user.username == ^username, select: user
    result = case Repo.all(query) do
      [] ->
        Logger.warn "No user matching username #{username}"
        {:error, :notfound}
      [user] ->
        Logger.info "User #{username} has ID #{user.id}"
        Repo.delete!(user)
        Logger.info "Succesfully deleted account n°#{user.id} : #{username}"
        {:ok, :deleted}
    end
  end

  def change_password(username, hpass) do
  end


  ### Backend API
  @spec process_id(String.t) :: {:ok, integer()} | {:error, :not_an_int}
  def process_id(id) when is_binary(id) do
    try do
      result = id
               |> String.trim
               |> String.to_integer
      {:ok, result}
    rescue
      _error ->
        {:error, :not_an_int}
    end
  end

  @spec get_id_informations(integer()) :: {:ok, %Item{}} | {:not_found, integer()}
  defp get_id_informations(id) when is_integer(id) do
    query = from item in Item, where: item.id == ^id, select: item
    case Repo.all(query) do
      []     -> {:not_found, id}
      [item] -> {:ok, item}
    end
  end

  @spec check_duplicate(String.t) :: {:ok, String.t} | {:duplicate, integer()}
  defp check_duplicate(name) do
    Logger.debug "Wondering if " <> inspect(name) <> " already exists…"
    query = from item in Item, where: item.name == ^name, select: item
    case Repo.all(query) do
      [] ->
        Logger.debug "Nope, doesn't."
        {:ok, name}
      [item] ->
        Logger.debug "Well, looks like it does."
        {:duplicate, item.id}
    end
  end

  def record({:duplicate, id}, _comments, _username), do: {:duplicate, id}
  def record({:ok, name}, comments, username) do
    user = Repo.get_by(User, username: username)
    item = Ecto.build_assoc user, :items, %{name: name, comments: comments}
    {:ok, item} = Repo.insert item
    {:ok, item.id}
  end

  defp parse_information({:ok, %Item{}=item}) do
    date = item.inserted_at |> Ecto.DateTime.to_string
    %Message{status: :success,
            message: "Item is available",
            info: %Info{
              username:  item.username,
              name:      item.name,
              id:        Integer.to_string(item.id),
              date:      date,
              comments:  item.comments
            }
          } 
  end

  defp parse_information({:not_found, id}) do
    %Message{status: :error,
             message: "Item not found",
             info: %Info{id: Integer.to_string(id)}
            }
  end

  defp parse_information({:error, :not_an_int}) do
    Exon.Server.protocol
  end
end
