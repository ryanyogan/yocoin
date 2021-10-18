defmodule Yocoin.Exchanges.BitstampClient do
  @moduledoc false

  alias Yocoin.Exchanges.Client
  alias Yocoin.{Exchanges, Trade, Ticker}
  require Client
  require Logger

  Client.defclient(
    exchange_name: "bitstamp",
    host: 'ws.bitstamp.net',
    port: 443,
    currency_pairs: ["btcusd", "ethusd", "ltcusd", "btceur", "etheur", "ltceur"]
  )

  @impl true
  def subscription_frames(currency_pairs) do
    Enum.map(currency_pairs, &subscription_frame/1)
  end

  defp subscription_frame(currency_pair) do
    msg =
      %{
        "event" => "bts:subscribe",
        "data" => %{
          "channel" => "live_trades_#{currency_pair}"
        }
      }
      |> Jason.encode!()

    {:text, msg}
  end

  @impl true
  def handle_ws_message(%{"event" => "trade"} = msg, state) do
    {:ok, trade} = message_to_trade(msg)
    Exchanges.broadcast(trade)

    {:noreply, state}
  end

  @impl true
  def handle_ws_message(msg, state) do
    Logger.debug(msg, label: "Unhandled Message")
    {:noreply, state}
  end

  @spec message_to_trade(map()) :: {:ok, Trade.t()} | {:error, any()}
  def message_to_trade(%{"data" => data, "channel" => "live_trades_" <> currency_pair})
      when is_map(data) do
    with :ok <- validate_required(data, ["amount_str", "price_str", "timestamp"]),
         {:ok, traded_at} <- timestamp_to_datetime(data["timestamp"]) do
      {:ok,
       Trade.new(
         ticker: Ticker.new(exchange_name(), currency_pair),
         price: data["price_str"],
         volume: data["amount_str"],
         traded_at: traded_at
       )}
    else
      {:error, _reason} = error ->
        error
    end
  end

  def message_to_trade(_msg), do: {:error, :invalid_trade_message}

  @spec timestamp_to_datetime(String.t()) :: {:ok, DateTime.t()} | {:error, atom()}
  def timestamp_to_datetime(ts) do
    case Integer.parse(ts) do
      {timestamp, _} ->
        DateTime.from_unix(timestamp)

      :error ->
        {:error, :invalid_timestamp_string}
    end
  end
end
