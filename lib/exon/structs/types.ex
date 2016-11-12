defmodule Exon.Types do

  defmodule Client do
    defstruct [
        username: "anon",
        socket:   nil,
        ip:       "",
        host:     "",
        authed:   nil,
        port:     0
    ]
  end

  defmodule Data do
    @derive [Poison.Encoder]
    @derive [Poison.Decoder]
    defstruct [
        author:   nil,
        name:     nil,
        id:       nil,
        date:     nil,
        comments: nil
    ]
  end

  defmodule Message do
    @derive [Poison.Encoder]
    @derive [Poison.Decoder]
    defstruct [
        :status,
        :message,
        data: %Exon.Types.Data{}
    ]
  end
end