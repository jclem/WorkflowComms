defmodule WorkflowCommsWeb.Verifier.Twilio do
  use WorkflowCommsWeb.Verifier

  @impl WorkflowCommsWeb.Verifier
  def verify(conn) do
    with {:ok, signature} <- get_one_header(conn, "x-twilio-signature"),
         :ok <- verify_request(conn, signature) do
      verify_body(conn)
    end
  end

  defp get_url(conn) do
    "https://#{conn.host}#{conn.request_path}?#{conn.query_string}"
  end

  defp verify_body(conn) do
    body_sha = conn.params["bodySHA256"]
    hash = :crypto.hash(:sha256, conn.private[:raw_body]) |> Base.encode16(case: :lower)

    if secure_compare(hash, body_sha) do
      :ok
    else
      {:error, :body_signature_mismatch}
    end
  end

  defp verify_request(conn, signature) do
    conn
    |> get_url()
    |> compute_signature()
    |> Base.encode64()
    |> secure_compare(signature)
    |> if do
      :ok
    else
      {:error, :signature_mismatch}
    end
  end

  def compute_signature(basestring) do
    :crypto.hmac(:sha, twilio_token(), basestring)
  end

  defp twilio_token do
    Env.get!(:workflow_comms_web, :twilio_token)
  end
end
