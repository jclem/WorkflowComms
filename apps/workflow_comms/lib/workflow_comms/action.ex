defmodule WorkflowComms.Action do
  @moduledoc """
  A struct representing an GitHub Actions action.
  """

  @type t :: %__MODULE__{}

  @derive [Poison.Encoder]
  defstruct id: nil, action: %{}, callback: %{}, type: nil, provider: nil, result: %{}, meta: %{}

  @doc """
  Set an ID on an action.

  If the action has an ID, don't change it.
  """
  def set_id(%{id: id} = axn) when is_binary(id), do: axn
  def set_id(axn), do: Map.put(axn, :id, Base62UUID.generate())
end
