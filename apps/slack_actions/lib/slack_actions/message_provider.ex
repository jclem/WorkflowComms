defmodule SlackActions.MessageProvider do
  @callback handle_action(SlackActions.Action.t()) :: :ok | {:error, term}
  @callback handle_callback(SlackActions.Action.t(), map()) ::
              {:ok, SlackActions.Action.t()} | {:error, term}

  defmacro __using__(_opts) do
    quote do
      @behaviour SlackActions.MessageProvider
      import SlackActions.MessageProvider
    end
  end
end
