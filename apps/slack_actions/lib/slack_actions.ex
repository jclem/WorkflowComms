defmodule SlackActions do
  @moduledoc """
  A module for storing action callbacks received by Slack and then updating
  action messages
  """

  @message_providers %{
    "slack" => SlackActions.MessageProvider.Slack,
    "twilio" => SlackActions.MessageProvider.Twilio
  }

  alias SlackActions.Action

  @doc """
  Handle an action.
  """
  @spec handle_action(Action.t()) :: :ok | {:error, term}
  def handle_action(action) do
    case @message_providers[action.provider] do
      mod when is_atom(mod) ->
        mod.handle_action(action)

      _ ->
        {:error, :no_such_provider}
    end
  end

  @doc """
  Store a callback and update its Slack message.
  """
  @spec handle_callback(String.t(), SlackActions.Callbacks.callback()) ::
          {:ok, Action.t()} | {:error, any}
  def handle_callback(provider, %{"callback_id" => cb_id} = callback) do
    with mod when is_atom(mod) <- @message_providers[provider],
         {:ok, action} <- SlackActions.Callbacks.get_action(cb_id),
         action = Map.put(action, :callback, callback),
         {:ok, action} <- mod.handle_callback(action, callback),
         {:ok, action} <- SlackActions.Callbacks.put_action(action) do
      {:ok, action}
    end
  end
end
