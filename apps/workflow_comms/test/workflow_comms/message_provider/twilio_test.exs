defmodule WorkflowComms.MessageProvider.TwilioTest do
  use ExUnit.Case

  import Mock

  require WorkflowComms.HTTPoisonMock

  alias WorkflowComms.{Action, HTTPoisonMock, TwilioAPI}
  alias WorkflowComms.MessageProvider.Twilio

  @workflow_url "https://example.com"
  @action %Action{id: "123", meta: %{"twilio_workflow_url" => @workflow_url}}

  @action_callback %{"action" => "confirm"}

  describe ".handle_action/1 confirm" do
    test_with_mock "kicks off a twilio url", TwilioAPI,
      post: HTTPoisonMock.post(@workflow_url, _body) do
      :ok = @action |> Map.put(:type, "confirm") |> Twilio.handle_action()

      assert_called(
        TwilioAPI.post(
          @workflow_url,
          %{
            To: @action.meta["to"],
            From: @action.meta["from"],
            Parameters: %{callback_id: @action.id}
          }
        )
      )
    end

    test_with_mock "returns an error when the request is unsuccessful", TwilioAPI,
      post: HTTPoisonMock.post(@workflow_url, _body, 400) do
      assert {:error, :non_200_response} ==
               @action |> Map.put(:type, "confirm") |> Twilio.handle_action()
    end
  end

  test ".handle_callback/2 updates the action with the callback" do
    assert {:ok, Map.put(@action, :result, %{"response" => @action_callback["action"]})} ==
             @action |> Twilio.handle_callback(@action_callback)
  end
end
