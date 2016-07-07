defmodule Exon.Database do
@moduledoc false

use GenServer
require Logger
alias Exon.{Item,Repo,User}
import Ecto.Query

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def get_id(id) when is_binary(id),        do: GenServer.call __MODULE__, {:get_id, id}
  def add_new_item(name, comments, client), do: GenServer.call __MODULE__, {:add_new_item, name, comments, client}
  def add_new_comment(id, comments),        do: GenServer.call __MODULE__, {:add_new_comment, id, comments}
  def add_new_user(username, password),     do: GenServer.call __MODULE__, {:add_new_user, username, password}
  def remove_item(id),                      do: GenServer.call __MODULE__, {:remove_item, id}
  def remove_user(username),                do: GenServer.call __MODULE__, {:remove_user, username}
  def change_passwd(username, hpass),       do: GenServer.call __MODULE__, {:change_passwd, username, hpass}

###############
# GenServer API
###############

  def init(state) do
    Logger.info(IO.ANSI.green <> "Database loaded." <> IO.ANSI.reset)
    {:ok, state}
  end

  def handle_call({:get_id, id}, _from, state) do
    result = (id |> String.strip |> String.to_integer) |> get_id_informations |> parse_informations
    {:reply, result, state}
  end

  def handle_call({:add_new_item, name, comments, client}, _from, state) do
    result = name |> String.downcase |> String.capitalize |> check_duplicate |> record(name, comments, client.username)
    {:reply, result, state}
  end

  def handle_call({:add_new_comment, id, new_comments}, _from, state) do
    result = comment(id, new_comments)
    {:reply, result, state}
  end

  def handle_call({:remove_item, id}, _from, state) do
    id = String.to_integer(id)
    result = case Repo.get(Item, id) do
      nil ->
        :error
      item ->
        Repo.delete!(item) && :ok
    end
    {:reply, result, state}
  end

  def handle_call({:remove_user, username}, _from, state) do
    query = from user in User, where: user.username == ^username, select: user
    result = case Repo.all(query) do
      [] ->
        Logger.warn "No user matching username #{username}"
        :error
      [user] ->
        Logger.info "User #{username} has ID #{user.id}"
        Repo.delete!(user)
        Logger.info "Succesfully deleted account n°#{user.id} : #{username}"
    end
    {:reply, result, state}
  end

  def handle_call({:change_passwd, username, hpass}, _from, state) do
    query = from user in User, where: user.username == ^username, select: user
    result = with [user] <- Repo.all(query),
          {:ok, _struct} <- Repo.update(%User{user | hashed_password: hpass}) do
           Logger.info "Successfully changed password for user #{username}"
    else
      {:error, _changeset} -> Logger.error "Could not change password for user #{username}"
      []                   -> Logger.error "User #{username} does not exist!"
    end
    {:reply, result, state}
  end

  def handle_call({:add_new_user, username, password}, _from, state) do
    result = case NotQwerty123.PasswordStrength.strong_password?(password) do
      true ->
        Logger.debug("Password strong enough")
        hpass = Comeonin.Pbkdf2.hashpwsalt(password)
        %User{username: username, hashed_password: hpass} |> Repo.insert
        Logger.debug("User #{username} registered!")
        {:ok, :registered}
      error_msg ->
        Logger.warn(error_msg)
        {:error, :weak_password}
    end
    {:reply, result, state}
  end

#############
# Backend API
#############

  defp get_id_informations(id) when is_integer(id) do
    query = from item in Item, where: item.id == ^id, select: item
    case Repo.all(query) do
      [] -> {:error, :id_not_found, id}
      [item] -> {:ok, item}
    end
  end

  # regarde la pipeline ligne 31 avant de te demander pourquoi _name et _comments sont là.
  defp record({:duplicate, id}, _name, _comments, _username), do: {:duplicate, id}
  defp record(:ok, name, comments, username) do
    name     = String.strip(name)  
    comments = String.strip(comments)

    {:ok, item} = Repo.insert(%Item{name: name, comments: comments, author: username})

    {:ok, item.id}
  end

  defp check_duplicate(name) do
    query = from item in Item, where: item.name == ^name, select: item
    case Repo.all(query) do
      [] -> :ok
      [item] -> {:duplicate, item.id}
    end
  end

  defp comment(id, new_comments) do
    query = from i in Exon.Item, where: i.id == ^id, select: i
    with [item] <- Repo.all(query),
         comments = item.comments <> "\n•" <> new_comments,
         {:ok, _model} <- Repo.update(Item.changeset(item, %{comments: comments})) do
      {:ok, :added}
    else
      []          -> {:error, "Item does not exist."}
      {:error, _} -> {:error, "Could not insert comment to database."}
    end
  end

  defp parse_informations({:ok, item}) do
    date = item.inserted_at |> Ecto.DateTime.to_string
    %{:status => :success,
      :message => "Item is available",
      :data => %{
        :author => item.author,
        :name => item.name,
        :id => item.id,
        :date => date,
        :comments => item.comments
      }
    }
  end

  defp parse_informations({:error, :id_not_found, id}) do
    %{:status => :error,
      :message => "Item not found",
      :data => %{
        :author => "",
        :name => "",
        :id   => id,
        :date => "",
        :comments => ""
      }
    }
  end
end
