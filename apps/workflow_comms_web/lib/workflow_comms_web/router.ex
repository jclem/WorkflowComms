defmodule WorkflowCommsWeb.Router do
  @moduledoc false

  require Logger

  @json_bad_request Poison.encode!(%{error: "bad_request"})
  @json_ok Poison.encode!(%{ok: true})
  @json_not_found Poison.encode!(%{error: "not_found"})
  @json_unprocessable_entity Poison.encode!(%{error: "unprocessable_entity"})

  @verifiers %{
    "slack" => WorkflowCommsWeb.Verifier.Slack,
    "twilio" => WorkflowCommsWeb.Verifier.Twilio,
    "test" => WorkflowCommsWeb.Verifier.Test
  }

  @decoders %{
    "slack" => WorkflowCommsWeb.Decoder.Slack,
    "twilio" => WorkflowCommsWeb.Decoder.Twilio,
    "test" => WorkflowCommsWeb.Decoder.Test
  }

  use Plug.Router

  alias WorkflowComms.Action

  if Mix.env() !== :test do
    plug(Plug.Logger)
  end

  plug(:match)
  plug(:json_response)

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["application/json", "application/x-www-form-urlencoded"],
    json_decoder: Poison,
    body_reader: {WorkflowCommsWeb.CopyBodyReader, :read_body, []}
  )

  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, @json_ok)
  end

  post "/actions" do
    action = Poison.Decode.transform(conn.body_params, %{as: %Action{}})

    with {:ok, action} <- WorkflowComms.Storage.put_action(action),
         :ok <- WorkflowComms.handle_action(action) do
      send_resp(conn, 201, Poison.encode!(action))
    else
      {:error, _} -> send_resp(conn, 422, @json_unprocessable_entity)
    end
  end

  get "/actions/:id" do
    case WorkflowComms.Storage.get_action(conn.path_params["id"]) do
      {:ok, action} -> send_resp(conn, 200, Poison.encode!(action))
      {:error, :not_found} -> send_resp(conn, 404, @json_not_found)
    end
  end

  post "/callbacks/:provider" do
    provider = conn.path_params["provider"]
    ver_mod = @verifiers[provider]
    dec_mod = @decoders[provider]

    with :ok <- ver_mod.verify(conn),
         {:ok, callback} <- dec_mod.decode(conn.body_params),
         {:ok, _action} <- WorkflowComms.handle_callback(conn.path_params["provider"], callback) do
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
end
