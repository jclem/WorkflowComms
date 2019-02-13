defmodule WorkflowCommsWeb.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock

  alias WorkflowCommsWeb.Router
  alias WorkflowCommsWeb.Verifier.Slack, as: SlackVerifier
  alias WorkflowComms.Action

  @opts Router.init([])

  setup do
    WorkflowComms.Callbacks.reset_state()
    :ok
  end

  test "GET /ping" do
    conn = conn(:get, "/ping") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ~s({"ok":true})
  end

  test "GET /actions/:id" do
    {:ok, action} = WorkflowComms.Callbacks.put_action(%Action{})

    callback = %{
      "callback_id" => action.id,
      "message_ts" => "123",
      "channel" => %{"id" => "id"}
    }

    {:ok, action} = WorkflowComms.Callbacks.put_action(%{action | callback: callback})

    conn =
      conn(:get, "/actions/#{action.id}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    body = Poison.decode!(conn.resp_body)
    assert body["id"] == action.id
    assert body["callback"] == callback
  end

  test "GET /actions/:id 404" do
    id = "123"

    conn =
      conn(:get, "/callbacks/#{id}")
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert Poison.decode!(conn.resp_body)["error"] == "not_found"
  end

  test_with_mock "POST /actions", WorkflowComms.SlackAPI, post: &mock_post/2 do
    body =
      Poison.encode!(%{
        provider: "slack",
        type: "confirm",
        action: %{GITHUB_ACTOR: "jclem"}
      })

    conn =
      conn(:post, "/actions", body)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201
    callback_id = Poison.decode!(conn.resp_body)["id"]
    {:ok, action} = WorkflowComms.Callbacks.get_action(callback_id)
    assert action.id == callback_id
  end

  test_with_mock "POST /callbacks/:provider", WorkflowComms.SlackAPI, post: &mock_post/2 do
    {:ok, action} = WorkflowComms.Callbacks.put_action(%Action{})

    body =
      URI.encode_query(
        payload:
          Poison.encode!(%{
            callback_id: action.id,
            message_ts: "123.456",
            channel: %{id: "ch_id"},
            actions: [%{name: "confirm"}]
          })
      )

    conn =
      conn(:post, "/callbacks/slack", body)
      |> sign_request(body)
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204

    {:ok, %{callback: callback}} = WorkflowComms.Callbacks.get_action(action.id)
    assert callback["callback_id"] == action.id
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
    |> put_req_header("x-slack-signature", SlackVerifier.compute_signature(body, timestamp))
    |> put_req_header("x-slack-request-timestamp", timestamp)
  end

  defp mock_post(_url, _body) do
    {:ok, %HTTPoison.Response{status_code: 200, body: %{"ok" => true}}}
  end
end
