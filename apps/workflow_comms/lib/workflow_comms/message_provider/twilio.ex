defmodule WorkflowComms.MessageProvider.Twilio do
  use WorkflowComms.MessageProvider

  alias WorkflowComms.{Action, TwilioAPI}

  @impl WorkflowComms.MessageProvider
  def handle_callback(action, callback) do
    response = Map.get(callback, "action")
    action = Map.put(action, :result, %{})
    action = put_in(action, [Access.key(:result), "response"], response)
    {:ok, action}
  end

  @impl WorkflowComms.MessageProvider
  def handle_action(action = %Action{type: "confirm"}) do
    TwilioAPI.post(
      action.meta["twilio_workflow_url"],
      %{
        To: action.meta["to"],
        From: action.meta["from"],
        Parameters: %{callback_id: action.id}
      }
    )
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200}} -> :ok
      {:ok, %HTTPoison.Response{}} -> {:error, :non_200_response}
      {:error, error} -> {:error, error}
    end
  end

  def handle(_action), do: {:error, :no_handler}
end
