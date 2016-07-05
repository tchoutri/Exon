defmodule Exon.Listener do
@moduledoc false

use GenServer
require Logger

  def start_link do
    GenServer.start_link(__MODULE__,[], name: Listener)
  end

  def init(_) do
    port    = Application.get_env(:exon, :port)
    address = Application.get_env(:exon, :bindto)
    Logger.info(IO.ANSI.green <> "Listening on #{address} on port #{port}" <> IO.ANSI.reset)
    case :gen_tcp.listen(port, [{:ip, parse_addr(address)}, inet(address), :binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, lsocket} -> 
        spawn(fn -> accept(lsocket) end)
        {:ok, lsocket}
      {:error, reason} -> {:stop, reason}
    end
  end

  defp accept(lsocket) do
    {:ok, socket} = :gen_tcp.accept(lsocket)
    case Exon.Session.start_link(socket) do
      {:ok, pid} ->
        :ok = :gen_tcp.controlling_process(socket, pid)
      error ->
        Logger.error "Could not start session (#{inspect error}), closing socket #{inspect socket}"
        :gen_tcp.close(socket)
    end

    accept(lsocket)
  end

  defp inet(address) do
    {:ok, ip} = :inet.parse_address(address)
    case tuple_size(ip) do
      4 -> :inet
      6 -> :inet6
    end
  end

  defp parse_addr(address) do
    {:ok, addr} = :inet.parse_address(address)
    addr
  end
end
