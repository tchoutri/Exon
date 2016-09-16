defmodule Exon.Server do
@moduledoc false

use GenServer
require Logger
alias Exon.Database

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: Server)
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Server started." <> IO.ANSI.reset)
    io_device = File.open!("log/exon.log", [:append])
    {:ok, io_device}
  end

  def get_id(id), do: GenServer.call(Server, {:id, id})
  def new_item(name, comments, client), do: GenServer.call(Server, {:new_item, name, comments, client})
  def new_comment(id, comments), do: GenServer.call(Server, {:new_comment, id, comments}) 
  def auth_user(credentials, client), do: GenServer.call(Server, {:auth, credentials, client})
  def del_item(:authed, id), do: GenServer.call(Server, {:del_item, id})
  def del_item(:non_authed, id) do
    Logger.debug "Non authed!"
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

  def handle_call({:new_item, name, comments, client}, _from, device=state) do
    message = case Database.add_new_item(name, comments, client) do
      {:ok, id} ->
        date = Ecto.DateTime.utc |> Ecto.DateTime.to_string
        IO.puts device, "[#{date}] Item ##{id} \"#{name}\" registered by #{client.username}" <> if(client.host == " (#{client.ip})", do: "", else: " (#{client.host})")
        %{:status => :success,
          :message => "New item registered",
          :data => Integer.to_string(id)
          } |> Poison.encode!

      {:duplicate, id} ->
        %{:status => :error,
          :message => "Item already exists",
          :data => Integer.to_string(id)
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
          :data => Integer.to_string(id)
          } |> Poison.encode!

      {:error, msg} ->
        %{:status => :error,
          :message => msg,
          :data => Integer.to_string(id)
         } |> Poison.encode!
      _ -> nil
    end
    {:reply, message <> "\n", state}
  end

  def handle_call({:auth, credentials, client}, _from, device=state) do
    date = Ecto.DateTime.utc |> Ecto.DateTime.to_string
    result = case Aeacus.authenticate %{identity: credentials[:identity], password: credentials[:passwd]} do
      {:ok, user}       -> 
        IO.puts device, "[#{date}] Successful authentication for #{user.username} (#{client.host})"
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

        IO.puts device, "[#{date}] Failed login for #{credentials[:identity]} (#{client.host})"

        Logger.warn "Failed login for " <> credentials[:identity]
        {:error, error, msg}
    end
    {:reply, result, state}
  end

  def handle_call({:del_item, id}, _from, state) do
    msg = case Database.del_item(id) do
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
