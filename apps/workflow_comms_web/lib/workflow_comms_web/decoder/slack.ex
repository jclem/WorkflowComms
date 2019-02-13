defmodule WorkflowCommmsWeb.Decoder.Slack do
  use WorkflowCommmsWeb.Decoder

  @impl WorkflowCommmsWeb.Decoder
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
