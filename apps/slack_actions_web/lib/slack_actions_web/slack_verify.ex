defmodule SlackActionsWeb.SlackVerify do
  @moduledoc """
  Verifies a request from Slack

  See https://api.slack.com/docs/verifying-requests-from-slack.
  """

  import SlackActionsWeb.SecureCompare

  @version "v0"

  def verify_request(signature, timestamp, body) do
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
    raw_signature = :crypto.hmac(:sha256, slack_signing_secret(), basestring)
    "#{@version}=#{Base.encode16(raw_signature)}"
  end

  defp get_basestring(timestamp, body) do
    "#{@version}:#{timestamp}:#{body}"
  end

  defp slack_signing_secret do
    case Application.get_env(:slack_actions_web, :slack_signing_secret) do
      {:system, key} -> System.get_env(key)
      value when is_binary(value) -> value
    end
  end
end
