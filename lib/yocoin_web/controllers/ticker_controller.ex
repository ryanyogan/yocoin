defmodule YocoinWeb.TickerController do
  use YocoinWeb, :controller

  def index(conn, _params) do
    trades =
      Yocoin.available_tickers()
      |> Yocoin.get_last_trades()

    render(conn, "index.html", trades: trades)
  end
end
