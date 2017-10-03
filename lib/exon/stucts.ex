defmodule Exon.Structs do

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

  defmodule Info do
    @derive [Poison.Decoder]
    defstruct [:username, :name, :id, :date, :comments]
  end

  defmodule Message do
    @derive [Poison.Decoder]
    @derive [Poison.Encoder]
    defstruct [
        :status,
        :message,
        info: %Exon.Structs.Info{}
    ]
  end

end
