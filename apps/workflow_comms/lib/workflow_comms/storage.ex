defmodule WorkflowComms.Storage do
  @moduledoc """
  Manages actions and callbacks received from Slack.
  """

  use GenServer

  require Logger

  alias WorkflowComms.Action

  @type callback :: %{required(String.t()) => String.t() | callback}

  @init_state %{}

  # Public API

  @doc """
  Put a new action into storage.
  """
  @spec put_action(Action.t()) :: {:ok, Action.t()}
  def put_action(action) do
    GenServer.call(__MODULE__, {:put_action, action})
  end

  @doc """
  Get an action by a given `id`.
  """
  @spec get_action(String.t()) :: {:ok, callback} | {:error, :not_found}
  def get_action(id) do
    GenServer.call(__MODULE__, {:get_action, id})
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

  def handle_call({:put_action, action}, _from, callbacks) do
    Logger.debug("Putting action #{inspect(action)}")

    action =
      if action.id do
        action
      else
        Map.put(action, :id, gen_action_id())
      end

    {:reply, {:ok, action}, Map.put(callbacks, action.id, action)}
  end

  def handle_call({:get_action, id}, _from, actions) do
    if action = Map.get(actions, id) do
      Logger.debug("Found action #{id}: #{inspect(action)}")
      {:reply, {:ok, action}, actions}
    else
      Logger.debug("Failed to find action #{id}")
      {:reply, {:error, :not_found}, actions}
    end
  end

  def handle_call(:reset_state, _from, _state) do
    {:reply, :ok, @init_state}
  end

  defp gen_action_id do
    Base62UUID.generate()
  end
end
