defmodule SlackConfirmTest do
  use ExUnit.Case
  doctest SlackConfirm

  test "greets the world" do
    assert SlackConfirm.hello() == :world
  end
end
