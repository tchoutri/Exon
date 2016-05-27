defmodule ExonTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, socket} = :gen_tcp.connect('localhost', 8878, [:binary, active: false])
    IO.puts("[ExUnit] Sending fake data")
    :gen_tcp.send(socket, ~s(add name="test1"::comments="A first comment"\n))
    {:ok, result} = :gen_tcp.recv(socket, 0)
    {:ok, [socket: socket]}
  end

  test "Protocol Validation #1 : ID", %{socket: socket} do
    IO.puts("[ExUnit] Protocol Validation #1 : ID")
    :ok = :gen_tcp.send(socket, "id 1\n")

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => %{"comments" => _, "date" => _,
                                 "id" => 1, "name" => "test1"}, "message" => "Item is available.",
                                 "status" => "success"} = data

   IO.puts "[ExUnit] Checking non-existing ID"
   :ok = :gen_tcp.send(socket, "id 324234\n")

   with {:ok, response} <- :gen_tcp.recv(socket, 0),
        {:ok, data}     <- Poison.decode(response),
        do: assert %{"data" => %{"comments" => "", "date" => "", "id" => 324234, "name" => ""},
                      "message" => "Item not found.", "status" => "error"} == data

  end

  test "Protocol Validation #2 : Comment", %{socket: socket} do
    IO.puts "[ExUnit] Protocol Validation #2 : Comment"
    :ok = :gen_tcp.send(socket, ~s(comment id="1"::comments="This is another comment""\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => 1, "message" => "New comment added.", "status" => "success"} == data
  end
end
