defmodule WorkflowComms.ActionTest do
  use ExUnit.Case, async: true

  alias WorkflowComms.Action

  @action %Action{}

  describe ".set_id/1" do
    test "adds an ID to the action" do
      assert Action.set_id(@action).id
    end

    test "keeps the same ID when an ID is already present" do
      action = Action.set_id(@action)
      assert Action.set_id(action).id == action.id
    end
  end
end
