defmodule WorkflowCommms.MessageProvider.Twilio do
  use WorkflowCommms.MessageProvider

  alias WorkflowCommms.Action

  @impl WorkflowCommms.MessageProvider
  def handle_callback(action, callback) do
    response = Map.get(callback, "action")
    action = Map.put(action, :result, %{})
    action = put_in(action, [Access.key(:result), "response"], response)
    {:ok, action}
  end

  @impl WorkflowCommms.MessageProvider
  def handle_action(action = %Action{type: "confirm"}) do
    HTTPoison.post!(
      action.meta["twilio_workflow_url"],
      URI.encode_query(
        To: action.meta["to"],
        From: action.meta["from"],
        Parameters: Poison.encode!(%{callback_id: action.id})
      ),
      [{"content-type", "application/x-www-form-urlencoded"}],
      hackney: [
        basic_auth:
          {Env.get!(:workflow_comms, :twilio_sid), Env.get!(:workflow_comms, :twilio_token)}
      ]
    )

    :ok
  end

  def handle(_action), do: {:error, :no_handler}
end
