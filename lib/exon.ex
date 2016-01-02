defmodule Exon do
  use Application

  def start(_type, _args) do
    Exon.Supervisor.start_link
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Exon.Endpoint.config_change(changed, removed)
    :ok
  end
end
