defmodule WorkflowCommsWeb.Decoder.Test do
  use WorkflowCommsWeb.Decoder

  @impl WorkflowCommsWeb.Decoder
  def decode(body_params) do
    {:ok, body_params}
  end
end
