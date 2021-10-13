defmodule Yocoin.Trade do
  alias Yocoin.Ticker

  @type t() :: %__MODULE__{
          ticker: Ticker.t(),
          traded_at: DateTime.t(),
          price: String.t(),
          volume: String.t()
        }

  defstruct [
    :ticker,
    :traded_at,
    :price,
    :volume
  ]

  @spec new(Keyword.t()) :: t()
  def new(fields) do
    struct!(__MODULE__, fields)
  end
end
