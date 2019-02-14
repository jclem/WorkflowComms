defmodule WorkflowComms.TwilioAPI do
  @moduledoc false

  use HTTPoison.Base

  def process_request_body(%{Parameters: parameters} = body) when is_map(parameters) do
    body
    |> Map.put(:Parameters, Poison.encode!(parameters))
    |> process_request_body
  end

  def process_request_body(body) do
    URI.encode_query(body)
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def process_request_options(options) do
    basic_auth = hackney_auth()

    Keyword.update(
      options,
      :hackney,
      Keyword.new(basic_auth: basic_auth),
      &Keyword.put_new(&1, :basic_auth, basic_auth)
    )
  end

  defp hackney_auth do
    {Env.get!(:workflow_comms, :twilio_sid), Env.get!(:workflow_comms, :twilio_token)}
  end
end
