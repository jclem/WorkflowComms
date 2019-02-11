defmodule SlackActions.Callbacks do
  use GenServer

  require Logger

  @init_state %{}

  # Public API

  def get_callback(callback_id) do
    GenServer.call(__MODULE__, {:get, callback_id})
  end

  def put_callback(callback_id, callback) do
    GenServer.call(__MODULE__, {:put, callback_id, callback})
  end

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
