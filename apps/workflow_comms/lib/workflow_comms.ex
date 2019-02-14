defmodule WorkflowComms do
  @moduledoc """
  A module for storing action callbacks received by Slack and then updating
  action messages
  """

  alias WorkflowComms.Action
  alias WorkflowComms.MessageProvider.{Slack, Twilio, Test}

  @doc """
  Handle an action.
  """
  @spec handle_action(Action.t()) :: :ok | {:error, term}
  def handle_action(%{provider: "slack"} = action), do: Slack.handle_action(action)
  def handle_action(%{provider: "twilio"} = action), do: Twilio.handle_action(action)
  def handle_action(%{provider: "test"} = action), do: Test.handle_action(action)
  def handle_action(_), do: {:error, :no_such_provider}

  @doc """
  Store a callback and update its Slack message.
  """
  @spec handle_callback(String.t(), WorkflowComms.Storage.callback()) ::
          {:ok, Action.t()} | {:error, any}
  def handle_callback("slack", callback), do: do_handle_callback(Slack, callback)
  def handle_callback("twilio", callback), do: do_handle_callback(Twilio, callback)
  def handle_callback("test", callback), do: do_handle_callback(Test, callback)
  def handle_callback(_, _), do: {:error, :no_such_provider}

  defp do_handle_callback(provider, %{"callback_id" => cb_id} = callback) do
    with {:ok, action} <- WorkflowComms.Storage.get_action(cb_id),
         action = Map.put(action, :callback, callback),
         {:ok, action} <- provider.handle_callback(action, callback),
         {:ok, action} <- WorkflowComms.Storage.put_action(action) do
      {:ok, action}
    end
  end
end
