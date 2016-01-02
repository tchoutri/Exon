defmodule Exon.PageController do
  use Exon.Web, :controller
  import Exon.Router.Helpers
  alias Exon.{Endpoint, QRCode}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def id(conn, %{"id" => id}) do
    result = GenServer.call(Server, {:id, id})
    conn |> put_resp_content_type("application/json")
         |> send_resp(200, result)
  end

  def qrcode(conn, %{"id" => id}) do
    item = Exon.Database.get_id("#{id}")
    case item.status do
      :error ->
        conn |> send_resp(404, "")
      :success ->
        file = page_url(Endpoint, :id, id) |> QRCode.make_qrcode
        conn |> put_resp_content_type("image/png")
             |> send_file(200, file)
    end
  end
end
