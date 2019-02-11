defmodule SlackActionsWeb.Router do
  @moduledoc false

  require Logger

  @json_not_found Poison.encode!(%{"error" => "not_found"})

  use Plug.Router

  if Mix.env() != :test, do: plug(Plug.Logger)

  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded], pass: ["application/x-www-form-urlencoded"])
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "OK")
  end

  get "/callbacks/:id" do
    case SlackActions.Callbacks.get_callback(conn.path_params["id"]) do
      {:ok, callback} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, Poison.encode!(callback))

      {:error, :not_found} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(404, @json_not_found)
    end
  end

  post "/callbacks" do
    with payload when is_binary(payload) <- Map.get(conn.body_params, "payload"),
         {:ok, callback} <- Poison.decode(payload),
         :ok <- SlackActions.handle_callback(callback) do
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Unable to save callback: #{inspect(err)}")
        send_resp(conn, 400, "Bad Request")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
