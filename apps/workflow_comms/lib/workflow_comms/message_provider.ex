defmodule WorkflowComms.MessageProvider do
  @callback handle_action(WorkflowComms.Action.t()) :: :ok | {:error, term}
  @callback handle_callback(WorkflowComms.Action.t(), map()) ::
              {:ok, WorkflowComms.Action.t()} | {:error, term}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowComms.MessageProvider
      import WorkflowComms.MessageProvider
    end
  end
end
