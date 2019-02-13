defmodule WorkflowCommsWeb.Verifier do
  @callback verify(Plug.Conn.t()) :: :ok | {:error, atom}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowCommsWeb.Verifier
      import WorkflowCommsWeb.Verifier
      import WorkflowCommsWeb.SecureCompare
    end
  end

  def get_one_header(conn, header) do
    case Plug.Conn.get_req_header(conn, header) do
      [value] -> {:ok, value}
      [_ | _] -> {:error, :too_many_header_values}
      [] -> {:error, :no_header_values}
    end
  end
end
