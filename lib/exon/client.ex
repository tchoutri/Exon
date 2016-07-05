defmodule Exon.Client do
  defstruct [
    username: "anon",
    socket: nil,
    ip: "",
    host: "",
    authed: nil,
    port: 0
  ]
end
