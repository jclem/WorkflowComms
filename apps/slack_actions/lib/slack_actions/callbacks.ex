defmodule SlackActions.Callbacks do
  @moduledoc """
  Manages callbacks received from Slack.
  """

  use GenServer

  require Logger

  @type callback :: %{required(String.t()) => String.t() | callback}

  @init_state %{}

  # Public API

  @doc """
  Get a callback by a given `callback_id`.
  """
  @spec get_callback(String.t()) :: {:ok, callback} | {:error, :not_found}
  def get_callback(callback_id) do
    GenServer.call(__MODULE__, {:get, callback_id})
  end

  @doc """
  Store a callback by its `callback_id`.
  """
  @spec put_callback(String.t(), callback) :: :ok
  def put_callback(callback_id, callback) do
    GenServer.call(__MODULE__, {:put, callback_id, callback})
  end

  @doc """
  Reset the server's state.

  This is only for use in testing.
  """
  @spec reset_state :: :ok
  def reset_state do
    GenServer.call(__MODULE__, :reset_state)
  end

  # GenServer functions

  def start_link({opts, start_opts} \\ {[], []}) do
    GenServer.start_link(__MODULE__, opts, start_opts)
  end

  def init(_opts) do
    {:ok, @init_state}
  end

  def handle_call({:get, callback_id}, _from, callbacks) do
    if callback = Map.get(callbacks, callback_id) do
      Logger.debug("Found callback #{callback_id}: #{inspect(callback)}")
      {:reply, {:ok, callback}, callbacks}
    else
      Logger.debug("Failed to find callback #{callback_id}")
      {:reply, {:error, :not_found}, callbacks}
    end
  end

  def handle_call({:put, callback_id, callback}, _from, callbacks) do
    Logger.debug("Putting callback #{callback_id}: #{inspect(callback)}")
    callbacks = Map.put(callbacks, callback_id, callback)
    {:reply, :ok, callbacks}
  end

  def handle_call(:reset_state, _from, _state) do
    {:reply, :ok, @init_state}
  end
end
