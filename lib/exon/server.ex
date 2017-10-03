defmodule Exon.Server do
  @moduledoc false

  use GenServer
  require Logger
  alias Exon.Structs.{Message,Info}
  alias Exon.{Repo, Database}
  alias Exon.Accounts.User

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: Server)
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Exon Server started." <> IO.ANSI.reset)
    unless File.exists?("log") do
      File.mkdir! "log"
    end
    io_device = File.open!("log/exon.log", [:append])
    {:ok, io_device}
  end

  def get_id(id),                       do: GenServer.call(Server, {:id, id})
  def new_item(name, comments, client), do: GenServer.call(Server, {:new_item, name, comments, client})
  def new_comment(id, comments),        do: GenServer.call(Server, {:new_comment, id, comments})
  def auth_user(client, credentials),   do: GenServer.call(Server, {:auth, credentials, client})
  def del_item(:authed, id),            do: GenServer.call(Server, {:del_item, id})
  def del_item(:non_authed, id) do
    Logger.debug "Non authed!"
    m = Poison.encode %Message{status: :error,
      message: "Unauthorized action - User not logged in",
      info: %Info{id: id}
    }
    m <> "\n"
  end

  def protocol do
     %Message{status: :error,
              message: "Protocol error, please refer to the documentation",
              info: %Info{}}
  end
  def handle_call({:new_item, name, comments, client}, _from, device=state) do
    message = case Database.add_new_item(name, comments, client) do
      {:ok, id} ->
        date = Ecto.DateTime.utc |> Ecto.DateTime.to_string
        IO.puts device, "[#{date}] ADD ITEM ##{id} \"#{name}\" BY #{client.username}" <> if(client.host ==
 " (#{client.ip})", do: "", else: " (#{client.host})")
        %Message{status:  :success,
                 message: "New item registered",
                 info:    %Info{id: Integer.to_string(id)}
          } |> Poison.encode!

      {:duplicate, id} ->
        %Message{status:  :error,
                 message: "Duplicate item",
                 info:    %Info{id: Integer.to_string(id)}
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
        %Message{status:  :success,
                 message: "New comment added",
                 info:    %Info{id: Integer.to_string(id)}
          } |> Poison.encode!

      {:error, msg} ->
        %Message{status: :error,
                 message: msg,
                 info:    %Info{id: Integer.to_string(id)}
         } |> Poison.encode!
      _ -> nil
    end
    {:reply, message <> "\n", state}
  end

  def handle_call({:auth, credentials, client}, _from, device=state) do
    date = Ecto.DateTime.utc |> Ecto.DateTime.to_string
    username = credentials[:identity]
    user = Repo.get_by(User, username: username)
    result = case Comeonin.Argon2.check_pass(user, credentials[:passwd]) do
      {:ok, user}       ->
        IO.puts device, "[#{date}] LOGIN SUCESSFUL #{user.username} (#{client.host})"
        Logger.debug "Sucessful authentication for " <> user.username
        msg = %Message{status: :success,
                       message: "Successful authentication",
                       info: %Info{username: user.username}
                      } |> Poison.encode!
        {:ok, user, msg}

      {:error, error} ->
        Logger.warn error
        msg = %Message{status: :error,
                       message: "Login failed; Invalid username or password",
                       info: %Info{username: username}
              } |> Poison.encode!

        IO.puts device, "[#{date}] LOGIN FAILED for #{credentials[:identity]} (#{client.host})"

        Logger.warn "Failed login for " <> credentials[:identity]
        {:error, error, msg}
    end
    {:reply, result, state}
  end

  def handle_call({:del_item, id}, _from, state) do
    msg = case Database.del_item(id) do
    :error -> %Message{status: :error,
                message: "Non-existing item",
                info: %Info{id: id}
              } |> Poison.encode!

    :ok ->  %Message{status: :success,
              message: "Item successfully deleted",
              info: %Info{id: id}
            } |> Poison.encode!
    end
    {:reply, msg, state}
  end
end
