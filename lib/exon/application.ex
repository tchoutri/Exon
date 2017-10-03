defmodule Exon.Application do
  use Application
  require Logger

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    Logger.info(IO.ANSI.green <> "Supervisor started." <> IO.ANSI.reset)
    
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Exon.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ExonWeb.Endpoint, []),
      # Start your own worker by calling: Exon.Worker.start_link(arg1, arg2, arg3)
      worker(Exon.Server, [], restart: :permanent),
      worker(Exon.Listener, [], restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
