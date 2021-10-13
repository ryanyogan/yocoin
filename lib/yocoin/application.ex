defmodule Yocoin.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Yocoin.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YocoinWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp children() do
    [
      YocoinWeb.Telemetry,
      {Phoenix.PubSub, name: Yocoin.PubSub},
      YocoinWeb.Endpoint
    ]
  end
end
