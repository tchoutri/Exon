defmodule ExonTest do
  use ExUnit.Case, async: true

  setup do
     {:ok, socket} = :gen_tcp.connect('localhost', 8878, [:binary, active: false])
     {:ok, [socket: socket]}
  end

  test "Protocol Validation:\tID", %{socket: socket} do
    :ok = :gen_tcp.send(socket, "id 1\n")

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => %{"comments" => "•This is a comment", "date" => _,
                                 "id" => 1, "name" => "Test1"}, "message" => "Item is available",
                                 "status" => "success"} = data
  end

  test "Protocol Validation:\tChecking non-existing ID", %{socket: socket} do
   :ok = :gen_tcp.send(socket, "id 324234\n")

   with {:ok, response} <- :gen_tcp.recv(socket, 0),
        {:ok, data}     <- Poison.decode(response),
        do: assert %{"data" => %{"comments" => "", "date" => "", "id" => 324234, "name" => ""},
                      "message" => "Item not found", "status" => "error"} == data
  end

  test "Protocol Validation:\tComment", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(comment id="3"::comments="¡This is another comment!"\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => 3, "message" => "New comment added",
                      "status" => "success"} == data
  end

  test "Protocol Validation:\tMalformed `comment` request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(comment id="1"::comments="FOOBARLOLZ”\n))
    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}     <- Poison.decode(response),
         do: assert %{"data" => nil, "message" => "Protocol error, please refer to the documentation",
                       "status" => "error"} == data
  end

  test "Protocol Validation:\tDuplicate items", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(add name="Test1"::comments="foobarlol"\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}     <- Poison.decode(response),
         do: assert %{"data" => _, "message" => "Item already exists",
                      "status" => "error"} = data
  end

  test "Protocol Validation:\t `add` request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(add name="Fusion engine"::comments="Could explode at any time."\n))
     with {:ok, response} <- :gen_tcp.recv(socket, 0),
          {:ok, data}     <- Poison.decode(response),
          do: assert %{"data" => _, "message" => "New item registered", "status" => "success"} = data
  end

  test "Protocol Validation:\tAccentuated `add` request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(add name="Truc qui fait des flammes"::comments="ÇA CHAAAAUFFE SA RAAAACE !!!!!"\n))
     with {:ok, response} <- :gen_tcp.recv(socket, 0),
          {:ok, data}     <- Poison.decode(response),
          do: assert %{"data" => _, "message" => "New item registered", "status" => "success"} = data
  end

  test "Protocol Validation:\tMalformed `add` request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(add name"=foo'::comments=“foobarlel"\n))
    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}     <- Poison.decode(response),
         do: assert %{"data" => nil, "message" => "Protocol error, please refer to the documentation",
                      "status" => "error"} == data
  end
end
