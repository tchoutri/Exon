defmodule Exon.TCP.Acceptor do
  use GenServer
  require Logger

  def start_link(l_socket) do
    GenServer.start_link(__MODULE__, l_socket, name: __MODULE__)
  end

  def init(l_socket)do
    GenServer.cast(__MODULE__, :listen)
    {:ok, l_socket}
  end
  def handle_cast(:listen, l_socket) do
    do_listen(l_socket)
  end

  def do_listen(l_socket) do
    case :gen_tcp.accept(l_socket) do
      {:ok, socket}     -> accept(l_socket, socket)
      {:error, :closed} -> do_listen(l_socket)
      {:error, _}       -> do_listen(l_socket)
    end
  end

  def accept(l_socket, socket) do
    case Exon.Server.start_session(socket) do
      {:ok, pid} -> :gen_tcp.controlling_process(socket, pid)
      error      -> Logger.error "Acceptor failed to start session (#{inspect error}), closing socket."
    end

    do_listen(l_socket)
  end


end
