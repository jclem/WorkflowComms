defmodule SlackActionsWeb.Router do
  @moduledoc false

  require Logger

  @json_bad_request Poison.encode!(%{error: "bad_request"})
  @json_ok Poison.encode!(%{ok: true})
  @json_not_found Poison.encode!(%{error: "not_found"})

  use Plug.Router

  alias SlackActionsWeb.SlackVerify

  if Mix.env() !== :test do
    plug(Plug.Logger)
  end

  plug(:match)
  plug(:json_response)

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["application/json", "application/x-www-form-urlencoded"],
    json_decoder: Poison,
    body_reader: {SlackActionsWeb.CopyBodyReader, :read_body, []}
  )

  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, @json_ok)
  end

  get "/callbacks/:id" do
    case SlackActions.Callbacks.get_callback(conn.path_params["id"]) do
      {:ok, callback} -> send_resp(conn, 200, Poison.encode!(callback))
      {:error, :not_found} -> send_resp(conn, 404, @json_not_found)
    end
  end

  post "/callbacks" do
    with :ok <- verify_request(conn),
         payload when is_binary(payload) <- Map.get(conn.body_params, "payload"),
         {:ok, callback} <- Poison.decode(payload),
         :ok <- SlackActions.handle_callback(callback) do
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Unable to save callback: #{inspect(err)}")
        send_resp(conn, 400, @json_bad_request)
    end
  end

  match _ do
    send_resp(conn, 404, @json_not_found)
  end

  defp json_response(conn, _opts) do
    put_resp_header(conn, "content-type", "application/json")
  end

  defp verify_request(conn) do
    with {:ok, signature} <- get_one_header(conn, "x-slack-signature"),
         {:ok, timestamp} <- get_one_header(conn, "x-slack-request-timestamp") do
      SlackVerify.verify_request(signature, timestamp, conn.private[:raw_body])
    end
  end

  defp get_one_header(conn, header) do
    case get_req_header(conn, header) do
      [value] -> {:ok, value}
      [_ | _] -> {:error, :too_many_header_values}
      [] -> {:error, :no_header_values}
    end
  end
end
