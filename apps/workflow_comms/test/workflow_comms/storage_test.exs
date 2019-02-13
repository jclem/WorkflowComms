defmodule WorkflowComms.StorageTest do
  use ExUnit.Case, async: true

  alias WorkflowComms.{Action, Storage}

  @test_action %Action{provider: "test"}

  setup do
    pid = start_supervised!({Storage, {[], []}})
    {:ok, %{storage: pid}}
  end

  describe ".put_action/1" do
    test "stores an action", %{storage: storage} do
      {:ok, action} = GenServer.call(storage, {:put_action, @test_action})
      assert {:ok, action} == GenServer.call(storage, {:get_action, action.id})
    end

    test "adds an ID for a new action", %{storage: storage} do
      {:ok, action} = GenServer.call(storage, {:put_action, @test_action})
      assert action.id
      assert {:ok, action} == GenServer.call(storage, {:get_action, action.id})
    end
  end

  describe ".get_action/1" do
    test "returns an action when found", %{storage: storage} do
      {:ok, action} = GenServer.call(storage, {:put_action, @test_action})
      assert {:ok, action} == GenServer.call(storage, {:get_action, action.id})
    end

    test "returns an error when not found", %{storage: storage} do
      assert {:error, :not_found} == GenServer.call(storage, {:get_action, @test_action.id})
    end
  end

  describe ".put_callback/2" do
    test "adds a callback to an action when found", %{storage: storage} do
      callback = %{foo: "bar"}
      {:ok, action} = GenServer.call(storage, {:put_action, @test_action})
      {:ok, action} = GenServer.call(storage, {:put_callback, action.id, callback})
      assert action.callback == callback
    end

    test "returns an error when the action is not found", %{storage: storage} do
      {:error, :not_found} = GenServer.call(storage, {:put_callback, @test_action.id, %{}})
    end
  end

  test ".reset_state/0 clears state", %{storage: storage} do
      {:ok, _} = GenServer.call(storage, {:put_action, @test_action})
      GenServer.call(storage, :reset_state)
      assert {:error, :not_found} == GenServer.call(storage, {:get_action, @test_action.id})
  end
end
