defmodule SlackActionsTest do
  use ExUnit.Case
  doctest SlackActions

  test "greets the world" do
    assert SlackActions.hello() == :world
  end
end
