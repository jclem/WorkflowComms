defmodule WorkflowCommmsWeb.Decoder do
  @callback decode(Plug.Conn.t()) :: {:ok, map} | {:error, atom}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowCommmsWeb.Decoder
      import WorkflowCommmsWeb.Decoder
    end
  end
end