defmodule WorkflowCommmsWeb.Decoder.Twilio do
  use WorkflowCommmsWeb.Decoder

  @impl WorkflowCommmsWeb.Decoder
  def decode(body_params) do
    {:ok, body_params}
  end
end
