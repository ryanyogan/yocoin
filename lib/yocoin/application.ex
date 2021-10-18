defmodule Yocoin.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Yocoin.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    YocoinWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp children() do
    [
      YocoinWeb.Telemetry,
      {Phoenix.PubSub, name: Yocoin.PubSub},
      {Yocoin.Historical, name: Yocoin.Historical},
      {Yocoin.Exchanges.Supervisor, name: Yocoin.Exchanges.Supervisor},
      YocoinWeb.Endpoint
    ]
  end
end
