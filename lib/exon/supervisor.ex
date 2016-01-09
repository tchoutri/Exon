defmodule Exon.Supervisor do
use Supervisor
require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Supervisor started." <> IO.ANSI.reset)
    children = [
      supervisor(Exon.Endpoint, []),
      supervisor(Exon.Repo, []),
      worker(Exon.Server, [], restart: :permanent),
      worker(Exon.Listener, [], restart: :permanent),
      worker(Exon.Database, [], restart: :permanent),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
