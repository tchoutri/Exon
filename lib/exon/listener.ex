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
    case :gen_tcp.accept(lsocket) do
      {:error, :closed} -> Logger.warn "Closing the connection"
      {:ok, socket}     ->
        case Exon.Session.start_link(socket) do
          {:ok, pid} ->
            :gen_tcp.controlling_process(socket, pid)
          {:error, reason} ->
          Logger.error "Could not start session (#{inspect reason})"
          Logger.error "Closing socket #{inspect socket}"
          :gen_tcp.close(socket)
        end
    end
    accept(lsocket)
  end

  defp inet(address) do
    {:ok, ip} = :inet.parse_address(address)
    case tuple_size(ip) do
      4 -> :inet
      8 -> :inet6
    end
  end

  defp parse_addr(address) do
    {:ok, addr} = :inet.parse_address(address)
    addr
  end
end
