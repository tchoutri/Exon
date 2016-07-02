defmodule Exon.Server do
@moduledoc false

use GenServer
require Logger
alias Exon.Database

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, [])
  end

  def init(socket) do
    Logger.debug "Started a server with PID #{inspect self}"
    spawn fn -> start_session(socket) end
    {:ok, socket}
  end

  def start_session(socket) do 
    Logger.debug("Handling session for #{inspect socket}")
    handle_session(socket)
  end

  def handle_session(socket),     do: GenServer.call(self, {:handle, socket})

  def get_id(id),                 do: GenServer.call(self, {:id, id})
  def new_item(name, comments),   do: GenServer.call(self, {:item, {name, comments}})
  def new_comment(id, comments),  do: GenServer.call(self, {:add_new_comment, id, comments}) 
  def protocol do
    %{:status => :error,
      :message => "Protocol error, please refer to the documentation",
      :data => nil
    } |> Poison.encode!
  end

  def handle_call({:handle, socket}, _from, state) do
    Logger.debug("Session handled for #{inspect socket}")
    Logger.debug("State is #{inspect state}")
    :timer.sleep(10000)
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
