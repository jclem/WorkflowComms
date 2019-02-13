defmodule WorkflowCommms.MessageProvider do
  @callback handle_action(WorkflowCommms.Action.t()) :: :ok | {:error, term}
  @callback handle_callback(WorkflowCommms.Action.t(), map()) ::
              {:ok, WorkflowCommms.Action.t()} | {:error, term}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowCommms.MessageProvider
      import WorkflowCommms.MessageProvider
    end
  end
end
