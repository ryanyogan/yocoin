defmodule YocoinWeb.PageController do
  use YocoinWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
