defmodule IracingStats.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Cache Iracing API data
      IracingStats.Cache,
      # Start the Telemetry supervisor
      IracingStatsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: IracingStats.PubSub},
      # Start the Endpoint (http/https)
      IracingStatsWeb.Endpoint
      # Start a worker by calling: IracingStats.Worker.start_link(arg)
      # {IracingStats.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IracingStats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IracingStatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
