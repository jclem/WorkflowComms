defmodule SlackActionsWeb.Router do
  @moduledoc false

  use Plug.Router

  if Mix.env() != :test, do: plug(Plug.Logger)

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
