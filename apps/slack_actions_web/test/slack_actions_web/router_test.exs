defmodule SlackActionsWeb.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias SlackActionsWeb.{Router, SlackVerify}

  @opts Router.init([])

  setup do
    SlackActions.Callbacks.reset_state()
    :ok
  end

  test "GET /ping" do
    conn = conn(:get, "/ping") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ~s({"ok":true})
  end

  test "GET /callbacks/:id" do
    id = "123"

    :ok =
      SlackActions.Callbacks.put_callback(
        id,
        %{
          "callback_id" => id,
          "message_ts" => "123",
          "channel" => %{"id" => "id"}
        }
      )

    conn =
      conn(:get, "/callbacks/#{id}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body)["callback_id"] == id
  end

  test "GET /callbacks/:id 404" do
    id = "123"

    conn =
      conn(:get, "/callbacks/#{id}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert Poison.decode!(conn.resp_body)["error"] == "not_found"
  end

  test "POST /callbacks" do
    callback_id = "abc123"

    body =
      URI.encode_query(
        payload: """
        {
          "callback_id": "#{callback_id}",
          "message_ts": "123.456",
          "channel": {"id": "ch_id"}
        }
        """
      )

    conn =
      conn(:post, "/callbacks", body)
      |> sign_request(body)
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204

    {:ok, callback} = SlackActions.Callbacks.get_callback(callback_id)
    assert callback["callback_id"] == callback_id
  end

  test "GET /not-found" do
    conn = conn(:get, "/not-a-route") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == ~s({"error":"not_found"})
  end

  defp sign_request(conn, body) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix() |> to_string

    conn
    |> put_req_header("x-slack-signature", SlackVerify.compute_signature(body, timestamp))
    |> put_req_header("x-slack-request-timestamp", timestamp)
  end
end
