defmodule WorkflowComms.MessageProvider.Test do
  @moduledoc false

  use WorkflowComms.MessageProvider

  @impl WorkflowComms.MessageProvider
  def handle_action(_action) do
    :ok
  end

  @impl WorkflowComms.MessageProvider
  def handle_callback(action, callback) do
    # For tests, just add the callback as the result.
    {:ok, put_in(action, [Access.key(:result), callback], true)}
  end
end
