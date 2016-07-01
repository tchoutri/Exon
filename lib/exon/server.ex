defmodule Exon.Server do
@moduledoc false

use GenServer
require Logger
alias Exon.Database

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: Server)
  end

  def start_session(socket),      do: {:ok, spawn(fn -> handle_session(socket) end)}
  def handle_session(socket),     do: GenServer.call(Socket, {:handle, socket})
  def get_id(id),                 do: GenServer.call(Server, {:id, id})
  def new_item(name, comments),   do: GenServer.call(Server, {:item, {name, comments}})
  def new_comment(id, comments),  do: GenServer.call(Server, {:add_new_comment, id, comments}) 
  def protocol do
    message = %{:status => :error,
                :message => "Protocol error, please refer to the documentation",
                :data => nil
              } |> Poison.encode!
    message <> "\n"
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Server started." <> IO.ANSI.reset)
    {:ok, :ok}
  end

  def handle_call({:handle, socket}, _from, state) do
    Logger.debug("Session handled for #{socket}")
    {:ok, state}
  end

  def handle_call({:item, {name, comments}}, _from, state) do
    message = Database.add_new_id(name, comments)
    {:reply, message, state}
  end

  def handle_call({:id, id}, _from, state) do
    message = Database.get_id(id)
    {:reply, message, state}
  end

  def handle_call({:add_new_comment, id, comments}, _from, state) do
    message = Database.add_new_comment(id, comments)
    {:reply, message, state}
  end
end
