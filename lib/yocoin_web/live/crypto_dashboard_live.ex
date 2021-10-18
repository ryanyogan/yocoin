defmodule YocoinWeb.CryptoDashboardLive do
  @moduledoc false

  use YocoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    tickers = Yocoin.available_tickers()

    trades =
      tickers
      |> Yocoin.get_last_trades()
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&{&1.ticker, &1})
      |> Enum.into(%{})

    if connected?(socket) do
      Enum.each(tickers, &Yocoin.subscribe_to_trades/1)
    end

    {:ok,
     socket
     |> assign(trades: trades)
     |> assign(tickers: tickers)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <table>
      <thead>
        <th>Traded at</th>
        <th>Exchange</th>
        <th>Currency</th>
        <th>Price</th>
        <th>Volume</th>
      </thead>
      <tbody>
      <%= for ticker <- @tickers, trade = @trades[ticker], not is_nil(trade) do %>
        <tr>
          <td><%= trade.traded_at %></td>
          <td><%= trade.ticker.exchange_name %></td>
          <td><%= trade.ticker.currency_pair %></td>
          <td><%= trade.price %></td>
          <td><%= trade.volume %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    """
  end

  @impl true
  def handle_info({:new_trade, trade}, socket) do
    socket =
      update(socket, :trades, fn trades ->
        Map.put(trades, trade.ticker, trade)
      end)

    {:noreply, socket}
  end
end
