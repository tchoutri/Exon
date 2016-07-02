defmodule Exon.TCP.Listener do
@moduledoc false

use Supervisor
require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    port    = Application.get_env(:exon, :port)
    address = Application.get_env(:exon, :bindto)
    {:ok, l_socket} = create_listen_socket(port, address)
    Logger.info(IO.ANSI.green <> "Listening on #{:inet.ntoa(address)} on port #{port}" <> IO.ANSI.reset)

    children = [
      worker(Exon.TCP.Acceptor, [l_socket], restart: :permanent)
    ]
    supervise(children, strategy: :one_for_one)
  end

  def create_listen_socket(port,address) do
    Logger.debug "Creating listening socket"
    :gen_tcp.listen(port, [{:ip, address}, :binary, packet: :line, active: false, reuseaddr: true])
  end

end
