defmodule Yocoin.Historical do
  use GenServer
  alias Yocoin.{Ticker, Trade, Exchanges}

  @type t() :: %__MODULE__{
          tickers: [Ticker.t()],
          trades: %{Ticker.t() => Trade.t()}
        }

  defstruct [:tickers, :trades]

  def start_link(opts) do
    {tickers, opts} = Keyword.pop(opts, :tickers, [])
    GenServer.start_link(__MODULE__, tickers, opts)
  end

  @spec get_last_trade(pid() | atom(), Ticker.t()) :: Trade.t() | nil
  def get_last_trade(pid \\ __MODULE__, ticker) do
    GenServer.call(pid, {:get_last_trade, ticker})
  end

  @spec get_last_trades(pid() | atom(), [Ticker.t()]) :: [Trade.t() | nil]
  def get_last_trades(pid \\ __MODULE__, tickers) do
    GenServer.call(pid, {:get_last_trades, tickers})
  end

  @impl true
  def init(tickers) do
    historical = %__MODULE__{tickers: tickers, trades: %{}}
    {:ok, historical, {:continue, :subscribe}}
  end

  @impl true
  def handle_continue(:subscribe, historical) do
    Enum.each(historical.tickers, &Exchanges.subscribe/1)
    {:noreply, historical}
  end

  @impl true
  def handle_info({:new_trade, trade}, historical) do
    updated_trades = Map.put(historical.trades, trade.ticker, trade)
    updated_historical = %{historical | trades: updated_trades}
    {:noreply, updated_historical}
  end

  @impl true
  def handle_call({:get_last_trade, ticker}, _from, historical) do
    trade = Map.get(historical.trades, ticker)
    {:reply, trade, historical}
  end

  @impl true
  def handle_call({:get_last_trades, tickers}, _from, historical) do
    trades = Enum.map(tickers, &Map.get(historical.trades, &1))
    {:reply, trades, historical}
  end
end
