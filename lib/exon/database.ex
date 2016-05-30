defmodule Exon.Database do
@moduledoc """
*TODO*
"""

use GenServer
require Logger
alias Exon.Item
alias Exon.Repo
import Ecto.Query

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def get_id(id) when is_binary(id), do:  GenServer.call(__MODULE__, {:get_id, id})
  def add_new_id(name, comments), do: GenServer.call(__MODULE__, {:add_new_id, name, comments})
  def add_new_comment(id, comments),   do: GenServer.call(__MODULE__, {:add_new_comment, id, comments})

###########
# GenServer API
###########

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Database loaded." <> IO.ANSI.reset)
    {:ok, :ok}
  end

  def handle_call({:get_id, id}, _from, :ok) do
    result = (id |> String.strip |> String.to_integer) |> get_id_informations |> parse_informations
    {:reply, result, :ok}
  end

  def handle_call({:add_new_id, name, comments}, _from, :ok) do
    result = name |> check_duplicate |> record(name, comments)
    {:reply, result, :ok}
  end

  def handle_call({:add_new_comment, id, new_comments}, _from, :ok) do
    result = comment(id, new_comments)
    {:reply, result, :ok}
  end

###########
# Backend API
###########

  defp get_id_informations(id) when is_integer(id) do
    query = from item in Item, where: item.id == ^id, select: item
    case Repo.all(query) do
      [] -> {:error, :id_not_found, id}
      [item] -> {:ok, item}
    end
  end

  defp record(:ok, name, comments) do
    name = String.strip(name)
    comments = String.strip(comments)

    {:ok, item} = Repo.insert(%Item{name: name, comments: "⋅" <> comments})

    {:ok, item.id}
  end

  defp record({:duplicate, id}, _name, _comments), do: {:duplicate, id}

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
         comments = item.comments <> "\n⋅" <> new_comments,
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
      :message => "Item is available.",
      :data => %{
        :name => item.name,
        :id => item.id,
        :date => date,
        :comments => item.comments
      }
    }
  end

  defp parse_informations({:error, :id_not_found, id}) do
    %{:status => :error,
      :message => "Item not found.",
      :data => %{
        :name => "",
        :id   => id,
        :date => "",
        :comments => ""
      }
    }
  end
end
