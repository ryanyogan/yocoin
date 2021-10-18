defmodule Yocoin.ExchangesTest do
  use ExUnit.Case, async: true
  alias Yocoin.{Exchanges, Ticker}

  test "available_tickers/0 returns all the available tickers" do
    assert MapSet.new(all_available_tickers()) ==
             MapSet.new(Exchanges.available_tickers())
  end

  defp all_available_tickers do
    [
      Ticker.new("coinbase", "BTC-USD"),
      Ticker.new("coinbase", "ETH-USD"),
      Ticker.new("coinbase", "LTC-USD"),
      Ticker.new("coinbase", "BTC-EUR"),
      Ticker.new("coinbase", "ETH-EUR"),
      Ticker.new("coinbase", "LTC-EUR"),
      Ticker.new("bitstamp", "btcusd"),
      Ticker.new("bitstamp", "ethusd"),
      Ticker.new("bitstamp", "ltcusd"),
      Ticker.new("bitstamp", "btceur"),
      Ticker.new("bitstamp", "etheur"),
      Ticker.new("bitstamp", "ltceur")
    ]
  end
end
