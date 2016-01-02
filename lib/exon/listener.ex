defmodule Exon.Listener do
@moduledoc """
*TODO*
"""
use GenServer
use Combine
require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: Listener)
  end

  def init(port) do
    address = Application.get_env(:exon, :bindto)
    Logger.info(IO.ANSI.green <> "Listening on #{:inet.ntoa(address)} on port #{port}" <> IO.ANSI.reset)
    spawn(fn -> listen(port) end)
    {:ok, port}
  end

  def listen(port) do
    address = Application.get_env(:exon, :bindto)
    {:ok, lsocket} = :gen_tcp.listen(port, [{:ip, address}, :binary, packet: :line, active: false, reuseaddr: true])
    accept(lsocket)
  end

  defp accept(lsocket) do
    {:ok, socket} = :gen_tcp.accept(lsocket)
    spawn(fn -> handle(socket) end)
    accept(lsocket)
  end

  defp handle(socket) do
    peer = peer_address(socket)
    case :gen_tcp.recv(socket, 0 ,:infinity) do
      {:ok, "quit" <> _rst} ->
        Logger.debug("[#{inspect(self)}] client from #{peer} closed the connection")
        :gen_tcp.close(socket)
      {:ok, data} ->
        :gen_tcp.send(socket, handler(data))
        handle(socket)
      {:error, :closed} ->
        Logger.debug("[#{inspect(self)}] client from #{peer} unexpectedly closed the connection")
      {:error, :einval} -> 
        Logger.warn("Something fucked up")
    end
  end

  defp handler(line) do
    parser = sep_by1(map(
    sequence([
      pair_left(word, char(?=)),
        # we use word_of here in order to treat whitespace characters as valid word characters
        between(char(?"), word_of(~r/[\w\s]/u), char(?"))
      ]),
        fn [key, value] -> {key, value} end),
        string("::"))

    case sanitize_linebreaks(line) do
      "id " <> id        -> Exon.Server.get_id(id)

      "add new " <> info -> parse_add_new(info, parser)
      "add comment " <> info -> parse_add_comment(info, parser)
      "" -> ""
      _  -> Exon.Server.protocol
    end
  end

  def sanitize_linebreaks(line) do
    if String.valid?(line) do
      line |> String.replace("\r", "") |> String.replace("\n", "")
    else 
      ""
    end
  end

  defp parse_add_new(info, parser) do
    case Combine.parse(info, parser) do
      [[{"name", name}, {"comments", comments}]] ->
        Exon.Server.new_item(name, comments)
      _ ->
        Exon.Server.protocol
    end
  end

  defp parse_add_comment(info, parser) do
    case Combine.parse(info, parser) do
      [[{"id", id}, {"comments", comments}]] ->
        Exon.Server.new_comment(String.to_integer(id), comments)
      _ ->
        Exon.Server.protocol
    end
  end

  defp peer_address(socket) do
    {:ok, {addr, _remote_port}} = :inet.peername(socket)
    addr |> Tuple.to_list |> Enum.join(".")
  end
end
