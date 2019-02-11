defmodule SlackConfirmWeb.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias SlackConfirmWeb.Router

  @opts Router.init([])

  test "GET /ping" do
    conn = conn(:get, "/ping") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "GET /not-found" do
    conn = conn(:get, "/not-a-route") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end
end
