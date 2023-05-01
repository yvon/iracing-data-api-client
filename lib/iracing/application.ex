defmodule Iracing.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [Iracing.Cache]

    Logger.info("Starting application...")
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
