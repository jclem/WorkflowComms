defmodule SlackActionsWeb.Decoder.Twilio do
  use SlackActionsWeb.Decoder

  @impl SlackActionsWeb.Decoder
  def decode(body_params) do
    {:ok, body_params}
  end
end
