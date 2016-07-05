defmodule Exon.Server do
@moduledoc false

use GenServer
require Logger
alias Exon.Database

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: Server)
  end

  def get_id(id), do: GenServer.call(Server, {:id, id})
  def new_item(name, comments, client), do: GenServer.call(Server, {:new_item, name, comments, client})
  def new_comment(id, comments), do: GenServer.call(Server, {:new_comment, id, comments}) 
  def auth_user(credentials), do: GenServer.call(Server, {:auth, credentials})
  def remove_item(:authed, id), do: GenServer.call(Server, {:remove_item, id})
  def remove_item(:non_authed, id) do
    m = %{status: :error,
      message: "Unauthorized action - User not logged in",
      data: id
    } |> Poison.encode!
    m <> "\n"
  end

  def protocol do
    m = %{:status => :error,
                :message => "Protocol error, please refer to the documentation",
                :data => nil
              } |> Poison.encode!
    m <> "\n"
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Server started." <> IO.ANSI.reset)
    {:ok, :ok}
  end

  def handle_call({:new_item, name, comments, client}, _from, state) do
    message = case Database.add_new_id(name, comments, client) do
      {:ok, id} ->
        %{:status => :success,
          :message => "New item registered",
          :data => id
          } |> Poison.encode!

      {:duplicate, id} ->
        %{:status => :error,
          :message => "Item already exists",
          :data => id
          } |> Poison.encode!
    end
    {:reply, message <> "\n", state}
  end

  def handle_call({:id, id}, _from, state) do
    message = id |> Database.get_id |> Poison.encode!
    {:reply, message <> "\n", state}
  end

  def handle_call({:new_comment, id, comments}, _from, state) do
    message = case Database.add_new_comment(id, comments) do
      {:ok, :added} ->
        %{:status => :success,
          :message => "New comment added",
          :data => id
          } |> Poison.encode!

      {:error, msg} ->
        %{:status => :error,
          :message => msg,
          :data => id
         } |> Poison.encode!
      _ -> nil
    end
    {:reply, message <> "\n", state}
  end

  def handle_call({:auth, credentials}, _from, state) do
    result = case Aeacus.authenticate %{identity: credentials[:identity], password: credentials[:passwd]} do
      {:ok, user}       -> 
        Logger.debug "Sucessful authentication for " <> user.username
        msg = %{status: :success,
                message: "Successful authentication",
                data: user.username
              } |> Poison.encode!
        {:ok, user, msg}

      {:error, error} -> 
        msg = %{status: :error,
                message: "Login failed; Invalid user ID or password",
                data: credentials[:identity]
              } |> Poison.encode!

        Logger.warn "Failed login for " <> credentials[:identity]
        Logger.warn error
        {:error, error, msg}
    end
    {:reply, result, state}
  end

  def handle_call({:remove_item, id}, _from, state) do
    msg = case Database.remove_item(id) do
    :error -> %{status: :error,
                message: "Non-existing item",
                data: id
            } |> Poison.encode!
 
    :ok ->  %{status: :success,
              message: "Item successfully deleted",
              data: id
            } |> Poison.encode!
    end
    {:reply, msg, state}
  end
end
