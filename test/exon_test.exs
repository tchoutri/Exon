defmodule ExonTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, socket} = :gen_tcp.connect('localhost', 8878, [:binary, active: false])
    IO.puts("[ExUnit] Sending fake data")
    :gen_tcp.send(socket, ~s(add name="test1"::comments="A first comment"\n))
    {:ok, _result} = :gen_tcp.recv(socket, 0)
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
  end

  test "Protocol Validation #2 Checking non-existing ID", %{socket: socket} do
    IO.puts "[ExUnit] Checking non-existing ID" 
   :ok = :gen_tcp.send(socket, "id 324234\n")

   with {:ok, response} <- :gen_tcp.recv(socket, 0),
        {:ok, data}     <- Poison.decode(response),
        do: assert %{"data" => %{"comments" => "", "date" => "", "id" => 324234, "name" => ""},
                      "message" => "Item not found.", "status" => "error"} == data

  end

  test "Protocol Validation #3 : Comment", %{socket: socket} do
    IO.puts "[ExUnit] Protocol Validation #2 : Comment"
    :ok = :gen_tcp.send(socket, ~s(comment id="1"::comments="This is another comment"\n))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}    <- Poison.decode(response),
         do: assert %{"data" => 1, "message" => "New comment added.", "status" => "success"} == data
  end

  ####### This one is currently failling for an unknown reason #######

#   1) test Protocol Validation #3 : Duplicate items (ExonTest)
#      test/exon_test.exs:42
#      ** (ExUnit.TimeoutError) test timed out after 60000ms. You can change the timeout:

#        1. per test by setting "@tag timeout: x"
#        2. per case by setting "@moduletag timeout: x"
#        3. globally via "ExUnit.start(timeout: x)" configuration
#        4. or set it to infinity per run by calling "mix test --trace"
#           (useful when using IEx.pry)

#      Timeouts are given as integers in milliseconds.

#      stacktrace:
#        :prim_inet.recv0/3
#        test/exon_test.exs:46
#        (ex_unit) lib/ex_unit/runner.ex:293: ExUnit.Runner.exec_test/1
#        (stdlib) timer.erl:166: :timer.tc/1
#        (ex_unit) lib/ex_unit/runner.ex:242: anonymous fn/3 in ExUnit.Runner.spawn_test/3


# Finished in 61.5 seconds (1.1s on load, 60.4s on tests)
# 3 tests, 1 failure

  test "Protocol Validation #4 : Duplicate items", %{socket: socket} do
    IO.puts "Protocol Validation #3 : Duplicate items"
    :ok = :gen_tcp.send(socket, ~s(add name="test1"::comments="foobarlol"))

    with {:ok, response} <- :gen_tcp.recv(socket, 0),
         {:ok, data}     <- Poison.decode(response),
         do: assert %{"data" => _, "message" => "Item already exists", "status" => "error"} = data
  end
end
