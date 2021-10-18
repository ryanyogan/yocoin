defmodule HistoricalTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias Yocoin.{Historical, Exchanges, Ticker, Trade}

  setup :start_fresh_historical_with_all_tickers
  setup :start_fresh_historical_with_all_coinbase_tickers
  setup :start_historical_with_trades_for_all_tickers

  describe "get_last_trade/2" do
    test "gets the most recent trade for a product", %{hist_all: historical} do
      ticker = coinbase_btc_usd_ticker()
      assert nil == Historical.get_last_trade(historical, ticker)

      # broadcast the trade
      trade = build_valid_trade(ticker)
      broadcast_trade(trade)
      assert trade == Historical.get_last_trade(historical, ticker)

      new_trade = build_valid_trade(ticker)
      assert :gt == DateTime.compare(new_trade.traded_at, trade.traded_at)

      broadcast_trade(new_trade)
      assert new_trade == Historical.get_last_trade(historical, ticker)
    end
  end

  describe "get_last_trades/2" do
    test "given a list of tickers, returns a list of most recent trades", %{
      hist_with_trades: historical
    } do
      tickers =
        Exchanges.available_tickers()
        |> Enum.shuffle()

      assert tickers ==
               historical
               |> Historical.get_last_trades(tickers)
               |> Enum.map(fn %Trade{ticker: t} -> t end)
    end

    test "nil in the returned list when the Historical doesn't have a trade for a ticker", %{
      hist_with_trades: historical
    } do
      tickers = [
        Ticker.new("coinbase", "BTC-USD"),
        Ticker.new("coinbase", "doesnt-exist"),
        Ticker.new("bitstamp", "btcusd")
      ]

      assert [%Trade{}, nil, %Trade{}] = Historical.get_last_trades(historical, tickers)
    end
  end

  test "keeps track of the trades for only the :tickers passwed when start", %{
    hist_coinbase: hist_coinbase
  } do
    coinbase_ticker = coinbase_btc_usd_ticker()

    # bitstamp trades are not received by historical that follows CB
    bitstamp_ticker = bitstamp_btc_usd_ticker()
    assert nil == Historical.get_last_trade(hist_coinbase, bitstamp_ticker)

    bitstamp_ticker
    |> build_valid_trade()
    |> broadcast_trade()

    assert nil == Historical.get_last_trade(hist_coinbase, bitstamp_ticker)

    # broadcast a coinbase trade, should be received
    assert nil == Historical.get_last_trade(hist_coinbase, coinbase_ticker)

    coinbase_trade = build_valid_trade(coinbase_ticker)
    broadcast_trade(coinbase_trade)
    assert coinbase_trade == Historical.get_last_trade(hist_coinbase, coinbase_ticker)
  end

  defp all_tickers, do: Exchanges.available_tickers()
  defp broadcast_trade(trade), do: Exchanges.broadcast(trade)
  defp coinbase_btc_usd_ticker, do: Ticker.new("coinbase", "BTC-USD")
  defp bitstamp_btc_usd_ticker, do: Ticker.new("bitstamp", "btcusd")

  defp all_coinbase_tickers do
    Exchanges.available_tickers()
    |> Enum.filter(&(&1.exchange_name == "coinbase"))
  end

  defp build_valid_trade(ticker) do
    %Trade{
      ticker: ticker,
      traded_at: DateTime.utc_now(),
      price: "10000.00",
      volume: "0.10000"
    }
  end

  defp start_fresh_historical_with_all_tickers(_context) do
    {:ok, hist_all} = Historical.start_link(tickers: all_tickers())
    [hist_all: hist_all]
  end

  defp start_fresh_historical_with_all_coinbase_tickers(_context) do
    {:ok, hist_coinbase} = Historical.start_link(tickers: all_coinbase_tickers())
    [hist_coinbase: hist_coinbase]
  end

  defp start_historical_with_trades_for_all_tickers(_context) do
    tickers = all_tickers()
    {:ok, hist} = Historical.start_link(tickers: tickers)
    Enum.each(tickers, &send(hist, {:new_trade, build_valid_trade(&1)}))
    [hist_with_trades: hist]
  end
end
