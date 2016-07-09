defmodule Exon.FormController do
  use Exon.Web, :controller

  def index(conn, %{"comments" => comments, "name" => name}) do
    case Exon.Database.add_new_item(name, comments, %Exon.User{}) do
      {:ok, id} ->
        conn |> put_flash(:info, "Item #{name} registered with id #{id}")
             |> render("index.html")
      {:duplicate, id} ->
        conn |> put_flash(:error, "Item #{name} already exists, with id #{id}")
             |> render("index.html")
      _ ->
        conn |> put_flash(:error, "Something went wrong.")
             |> render("index.html")
    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
