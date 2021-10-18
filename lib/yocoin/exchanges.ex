defmodule Yocoin.Exchanges do
  alias Yocoin.{Ticker, Trade}

  @clients [
    Yocoin.Exchanges.CoinbaseClient,
    Yocoin.Exchanges.BitstampClient
  ]

  @available_tickers (for client <- @clients, pair <- client.available_currency_pairs() do
                        Ticker.new(client.exchange_name(), pair)
                      end)

  @spec available_tickers() :: [Ticker.t()]
  def available_tickers(), do: @available_tickers

  @spec clients() :: [module()]
  def clients, do: @clients

  @spec subscribe(Ticker.t()) :: :ok | {:error, term()}
  def subscribe(ticker) do
    Phoenix.PubSub.subscribe(Yocoin.PubSub, topic(ticker))
  end

  @spec unsubscribe(Ticker.t()) :: :ok | {:error, term()}
  def unsubscribe(ticker) do
    Phoenix.PubSub.unsubscribe(Yocoin.PubSub, topic(ticker))
  end

  @spec broadcast(Trade.t()) :: :ok | {:error, term()}
  def broadcast(trade) do
    Phoenix.PubSub.broadcast(Yocoin.PubSub, topic(trade.ticker), {:new_trade, trade})
  end

  @spec topic(Ticker.t()) :: String.t()
  defp topic(ticker) do
    to_string(ticker)
  end
end
