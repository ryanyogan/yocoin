defmodule Yocoin.Exchanges do
  alias Yocoin.{Ticker, Trade}

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
