defmodule ExonWeb.PageController do
  use ExonWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
