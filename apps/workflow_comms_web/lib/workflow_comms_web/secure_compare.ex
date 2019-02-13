defmodule WorkflowCommsWeb.SecureCompare do
  @moduledoc """
  Performs constant-time comparison on strings of equal length
  """

  use Bitwise, only_operators: true

  @doc """
  Perform a constant-time comparison on two strings.

      iex> WorkflowCommsWeb.SecureCompare.secure_compare("foo", "")
      false

      iex> WorkflowCommsWeb.SecureCompare.secure_compare("foo", "bar")
      false

      iex> WorkflowCommsWeb.SecureCompare.secure_compare("foo", "foo")
      true
  """
  @spec secure_compare(Strint.t(), String.t()) :: boolean
  def secure_compare(a, b) when byte_size(a) != byte_size(b), do: false

  def secure_compare(a, b) do
    a
    |> to_charlist
    |> Enum.zip(to_charlist(b))
    |> Enum.reduce(0, &compare/2) == 0
  end

  defp compare({a_byte, b_byte}, res) do
    res ||| a_byte ^^^ b_byte
  end
end
