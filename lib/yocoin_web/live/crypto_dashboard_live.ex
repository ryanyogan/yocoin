defmodule YocoinWeb.CryptoDashboardLive do
  @moduledoc false

  use YocoinWeb, :live_view
  alias Yocoin.Ticker

  @impl true
  def mount(_params, _session, socket) do
    ticker = Ticker.new("coinbase", "BTC-USD")
    trade = Yocoin.get_last_trade(ticker)

    if connected?(socket) do
      Yocoin.subscribe_to_trades(ticker)
    end

    socket = assign(socket, :trade, trade)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <h2>
        <%= @trade.ticker.exchange_name %>
        <%= @trade.ticker.currency_pair %>
      </h2>
      <p>
        <%= @trade.traded_at %> -
        <%= @trade.price %> -
        <%= @trade.volume %>
      </p>
    """
  end

  @impl true
  def handle_info({:new_trade, trade}, socket) do
    socket = assign(socket, :trade, trade)
    {:noreply, socket}
  end
end
