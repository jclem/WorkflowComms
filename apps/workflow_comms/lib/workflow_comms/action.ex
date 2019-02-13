defmodule WorkflowCommms.Action do
  @type t :: %__MODULE__{}

  @derive [Poison.Encoder]
  defstruct id: nil, action: %{}, callback: %{}, type: nil, provider: nil, result: %{}, meta: %{}
end
