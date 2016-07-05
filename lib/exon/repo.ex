defmodule Exon.Repo do
  use Ecto.Repo, otp_app: :exon, adapter: Sqlite.Ecto
end
