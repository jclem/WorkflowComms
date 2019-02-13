defmodule WorkflowCommsWeb.Decoder.Slack do
  use WorkflowCommsWeb.Decoder

  @impl WorkflowCommsWeb.Decoder
  def decode(body_params) do
    with payload when is_binary(payload) <- Map.get(body_params, "payload"),
         {:ok, callback} when is_map(callback) <- Poison.decode(payload) do
      {:ok, callback}
    else
      _ ->
        {:error, :invalid_body}
    end
  end
end
