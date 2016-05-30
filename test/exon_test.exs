defmodule ExonTest do
  use ExUnit.Case, async: true

  setup do
     {:ok, socket} = :gen_tcp.connect('localhost', 8878, [:binary, active: false])
     {:ok, [socket: socket]}
  end

  test "Protocol Validation #1 : ID", %{socket: socket} do
    Exon.Server.new_item("test1", "This is a comment")
    :ok = :gen_tcp.send(socket, "id 1\n")

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => %{"comments" => _, "date" => _,
                                 "id" => 1, "name" => "test1"}, "message" => "Item is available.",
                                 "status" => "success"} = data
  end

  test "Protocol Validation #2 Checking non-existing ID", %{socket: socket} do
   :ok = :gen_tcp.send(socket, "id 324234\n")

   with {:ok, response} <- :gen_tcp.recv(socket, 0),
        {:ok, data}     <- Poison.decode(response),
        do: assert %{"data" => %{"comments" => "", "date" => "", "id" => 324234, "name" => ""},
                      "message" => "Item not found.", "status" => "error"} == data

  end

  test "Protocol Validation #3 : Comment", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(comment id="1"::comments="This is another comment"\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => 1, "message" => "New comment added.", "status" => "success"} == data
  end

  test "Protocol Validation #4 : Duplicate items", %{socket: socket} do
    Exon.Server.new_item("test1", "This is another comment")
    :ok = :gen_tcp.send(socket, ~s(add name="test1"::comments="foobarlol"\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}     <- Poison.decode(response),
         do: assert %{"data" => _, "message" => "Item already exists", "status" => "error"} = data
  end
end
