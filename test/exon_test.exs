defmodule ExonTest do
  use ExUnit.Case, async: true

  alias Exon.User
  setup do
    
     {:ok, socket} = :gen_tcp.connect({0,0,0,0,0,0,0,1}, 8878, [:binary, active: false])
     {:ok, [socket: socket]}
  end

  test "Protocol Validation:\tRequesting an ID", %{socket: socket} do
    :ok = :gen_tcp.send(socket, "id 1\n")

    {:ok, json} = :gen_tcp.recv(socket, 0)
    {:ok, response} = Poison.decode(json)
      assert response["data"]["comments"] == "This is a comment"
      assert response["data"]["id"]       == 1
      assert response["data"]["name"]     == "Test1"
      assert response["data"]["author"]   == "anon"
      assert response["message"]          == "Item is available"
      assert response["status"]           == "success"
  end

  test "Protocol Validation:\tChecking non-existing ID", %{socket: socket} do
    :ok = :gen_tcp.send(socket, "id 324234\n")

    {:ok, json} = :gen_tcp.recv(socket, 0)
    {:ok, response} = Poison.decode(json)
      assert response["data"]["id"] == 324234
      assert response["status"]     == "error"
      assert response["message"]    == "Item not found"
  end

  test "Protocol Validation:\tAuthentication request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(auth username="nixon"::passwd="hunter2"\n))
    {:ok, json} = :gen_tcp.recv(socket, 0)
    {:ok, response} = Poison.decode(json)
      assert response["status"]  == "success"
      assert response["message"] == "Successful authentication"
      assert response["data"]    == "nixon"
  end

  test "Protocol Validation:\tFailed authentication request", %{socket: socket} do
    :ok = :gen_tcp.send(socket, ~s(auth username="clinton"::passwd="hunter3"\n))
    {:ok, json} = :gen_tcp.recv(socket, 0)
    {:ok, response} = Poison.decode(json)

    assert response["status"]  == "error"
    assert response["message"] == "Login failed; Invalid user ID or password"
    assert response["data"]    == "clinton"
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

  test "Protocol Validation:\tAdding a new item", %{socket: socket} do
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
