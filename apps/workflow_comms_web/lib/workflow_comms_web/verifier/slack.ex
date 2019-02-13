defmodule WorkflowCommmsWeb.Verifier.Slack do
  @slack_api_vsn "v0"

  use WorkflowCommmsWeb.Verifier

  @impl WorkflowCommmsWeb.Verifier
  def verify(conn) do
    with {:ok, signature} <- get_one_header(conn, "x-slack-signature"),
         {:ok, timestamp} <- get_one_header(conn, "x-slack-request-timestamp") do
      verify_request(signature, timestamp, conn.private[:raw_body])
    end
  end

  defp verify_request(signature, timestamp, body) do
    body
    |> compute_signature(timestamp)
    |> secure_compare(signature)
    |> if do
      :ok
    else
      {:error, :signature_mismatch}
    end
  end

  def compute_signature(body, timestamp) do
    basestring = get_basestring(timestamp, body)
    slack_signing_secret = Env.get!(:workflow_comms_web, :slack_signing_secret)
    raw_signature = :crypto.hmac(:sha256, slack_signing_secret, basestring)

    "#{@slack_api_vsn}=#{Base.encode16(raw_signature, case: :lower)}"
  end

  defp get_basestring(timestamp, body) do
    "#{@slack_api_vsn}:#{timestamp}:#{body}"
  end
end
