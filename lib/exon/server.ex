defmodule Exon.Server do
@moduledoc false

use GenServer
require Logger
alias Exon.Database

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: Server)
  end

  def get_id(id), do: GenServer.call(Server, {:id, id})
  def new_item(name, comments), do: GenServer.call(Server, {:item, {name, comments}})
  def new_comment(id, comments), do: GenServer.call(Server, {:add_new_comment, id, comments}) 
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

  def handle_call({:item, {name, comments}}, _from, state) do
    message = case Database.add_new_id(name, comments) do
      {:ok, id} ->
        %{:status => :success,
          :message => "New item registered.",
          :data => id
          } |> Poison.encode!

      {:duplicate, id} ->
        %{:status => :error,
          :message => "Item already exists",
          :data => id
          } |> Poison.encode!
    end
    {:reply, message <> "\n\n", state}
  end

  def handle_call({:id, id}, _from, state) do
    message = id |> Database.get_id |> Poison.encode!
    {:reply, message, state}
  end

  def handle_call({:add_new_comment, id, comments}, _from, state) do
    message = case Database.add_new_comment(id, comments) do
      {:ok, :added} ->
        %{:status => :success,
          :message => "New comment added.",
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
end
