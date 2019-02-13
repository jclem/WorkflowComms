defmodule WorkflowCommsWeb.Verifier.Test do
  use WorkflowCommsWeb.Verifier

  @impl WorkflowCommsWeb.Verifier
  def verify(_conn) do
    :ok
  end
end
