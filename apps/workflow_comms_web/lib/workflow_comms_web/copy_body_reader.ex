defmodule WorkflowCommsWeb.CopyBodyReader do
  @moduledoc """
  This module provides a `read_body/2` function that copies a request body into
  a connection's private properties.
  """

  @spec read_body(Plug.Conn.t(), Keyword.t()) :: {:ok, String.t(), Plug.Conn.t()}
  def read_body(conn, opts) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn, opts) do
      conn = Plug.Conn.put_private(conn, :raw_body, body)
      {:ok, body, conn}
    end
  end
end
