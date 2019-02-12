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
    |> Keyword.put(:token, Env.get!(:slack_actions, :slack_token))
    |> URI.encode_query()
  end
end
