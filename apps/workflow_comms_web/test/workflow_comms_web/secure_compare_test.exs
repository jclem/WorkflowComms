defmodule WorkflowCommmsWeb.SecureCompareTest do
  use ExUnit.Case, async: true
  doctest WorkflowCommmsWeb.SecureCompare

  alias WorkflowCommmsWeb.SecureCompare

  describe ".secure_compare/2" do
    test "is false when lengths differ" do
      refute SecureCompare.secure_compare("foo", "fo")
    end

    test "is false when values differ" do
      refute SecureCompare.secure_compare("foo", "bar")
    end

    test "is true when values are equal" do
      assert SecureCompare.secure_compare("foo", "foo")
    end
  end
end
