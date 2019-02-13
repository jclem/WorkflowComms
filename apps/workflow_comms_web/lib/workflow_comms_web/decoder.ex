defmodule WorkflowCommsWeb.Decoder do
  @callback decode(Plug.Conn.t()) :: {:ok, map} | {:error, atom}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowCommsWeb.Decoder
      import WorkflowCommsWeb.Decoder
    end
  end
end
