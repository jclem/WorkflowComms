defmodule WorkflowComms.MessageProvider.SlackTest do
  use ExUnit.Case

  import Mock

  require WorkflowComms.HTTPoisonMock

  alias WorkflowComms.{Action, HTTPoisonMock, SlackAPI}
  alias WorkflowComms.MessageProvider.Slack

  @action %Action{meta: %{"channel_id" => "channel_id", "text" => "text"}}

  @action_callback %{
    "message_ts" => DateTime.to_unix(DateTime.utc_now()),
    "actions" => [%{"name" => "confirm"}]
  }

  describe ".handle_action/1 notify" do
    test_with_mock "posts to Slack", SlackAPI,
      post: HTTPoisonMock.post("/chat.postMessage", _body) do
      :ok = @action |> Map.put(:type, "notify") |> Slack.handle_action()

      assert_called(
        SlackAPI.post("/chat.postMessage",
          channel: "channel_id",
          token: "abc-123",
          text: "text"
        )
      )
    end

    test_with_mock "returns an error when the request is unsuccessful", SlackAPI,
      post: HTTPoisonMock.post("/chat.postMessage", _body, 200, %{"ok" => false}) do
      assert {:error, %HTTPoison.Response{status_code: 200, body: %{"ok" => false}}} ==
               @action |> Map.put(:type, "notify") |> Slack.handle_action()
    end
  end

  describe ".handle_action/1 confirm" do
    test_with_mock "posts to Slack", SlackAPI,
      post: HTTPoisonMock.post("/chat.postMessage", _body) do
      :ok = @action |> Map.put(:type, "confirm") |> Slack.handle_action()

      assert_called(
        SlackAPI.post("/chat.postMessage",
          channel: "channel_id",
          token: "abc-123",
          attachments: :_
        )
      )
    end
  end

  describe ".handle_callback/2" do
    test_with_mock "updates the Slack message", SlackAPI,
      post: HTTPoisonMock.post("/chat.update", _body) do
      {:ok, _} = Slack.handle_callback(@action, @action_callback)

      assert_called(
        SlackAPI.post("/chat.update",
          channel: "channel_id",
          ts: @action_callback["message_ts"],
          text: nil,
          attachments: nil
        )
      )
    end

    test_with_mock "updates the action with the callback", SlackAPI,
      post: HTTPoisonMock.post("/chat.update", _body) do
      {:ok, action} = Slack.handle_callback(@action, @action_callback)
      assert action.result["response"] == "confirm"
    end
  end
end
