defmodule Env do
  @moduledoc """
  Reads application configuration
  """

  @doc """
  Read an application config.

      iex> Application.put_env(:env, :foo, :bar)
      iex> Env.get(:env, :foo)
      {:ok, :bar}

      iex> Application.delete_env(:env, :foo)
      iex> Env.get(:env, :foo)
      {:error, :not_found}
  """
  @spec get(atom, atom) :: {:ok, any} | {:error, :not_found}
  def get(application, key) do
    application
    |> Application.get_env(key)
    |> case do
      {:system, key} -> System.get_env(key)
      value -> value
    end
    |> case do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  @doc """
  Read an application config, but raise if it is not present.

      iex> Application.put_env(:env, :foo, :bar)
      iex> Env.get!(:env, :foo)
      :bar
  """
  @spec get!(atom, atom) :: any | no_return
  def get!(application, key) do
    case get(application, key) do
      {:ok, value} -> value
      _ -> raise "No value found for key #{key}"
    end
  end
end
