defmodule Yocoin do
  @moduledoc """
  Yocoin keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  defdelegate available_tickers(), to: Yocoin.Exchanges
  defdelegate subscribe_to_trades(ticker), to: Yocoin.Exchanges, as: :subscribe
  defdelegate unsubscribe_to_trades(ticker), to: Yocoin.Exchanges, as: :unsubscribe
  defdelegate get_last_trade(ticker), to: Yocoin.Historical
  defdelegate get_last_trades(tickers), to: Yocoin.Historical
end
