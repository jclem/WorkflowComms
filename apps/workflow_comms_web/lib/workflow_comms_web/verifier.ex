defmodule WorkflowCommmsWeb.Verifier do
  @callback verify(Plug.Conn.t()) :: :ok | {:error, atom}

  defmacro __using__(_opts) do
    quote do
      @behaviour WorkflowCommmsWeb.Verifier
      import WorkflowCommmsWeb.Verifier
      import WorkflowCommmsWeb.SecureCompare
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
