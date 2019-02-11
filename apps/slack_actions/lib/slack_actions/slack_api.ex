defmodule SlackActions.SlackAPI do
  @moduledoc false

  use HTTPoison.Base

  @endpoint "https://slack.com/api"

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def process_request_body(body) do
    body
    |> Keyword.put(:token, slack_bot_token())
    |> URI.encode_query()
  end

  defp slack_bot_token do
    case Application.get_env(:slack_actions, :slack_token) do
      {:system, key} ->
        System.get_env(key)

      key when is_binary(key) ->
        key
    end
  end
end
