defmodule WorkflowCommms.SlackAPI do
  @moduledoc false

  use HTTPoison.Base

  @endpoint "https://slack.com/api"

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def process_request_body(body) when is_list(body) do
    body
    |> Keyword.put(:token, Env.get!(:workflow_comms, :slack_token))
    |> URI.encode_query()
  end

  def process_request_body(body), do: body

  def process_response_body(body), do: Poison.decode!(body)
end
