defmodule SlackActionsWeb.Decoder do
  @callback decode(Plug.Conn.t()) :: {:ok, map} | {:error, atom}

  defmacro __using__(_opts) do
    quote do
      @behaviour SlackActionsWeb.Decoder
      import SlackActionsWeb.Decoder
    end
  end
end
