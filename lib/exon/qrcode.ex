defmodule Exon.QRCode do
@moduledoc false
  def make_qrcode(link) do
    uri = URI.parse(link)
    filename = "/tmp/exon" <> (uri.path |> String.replace("/", "-")) <> ".png"
    qrcode = :qrcode.encode(link)
    image = :qrcode_demo.simple_png_encode(qrcode)
    File.write(filename, image)
    filename
  end
end
