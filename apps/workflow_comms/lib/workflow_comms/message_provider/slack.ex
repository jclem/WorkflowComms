defmodule WorkflowCommms.MessageProvider.Slack do
  use WorkflowCommms.MessageProvider

  require Logger

  alias WorkflowCommms.{Action, SlackAPI}
  alias HTTPoison.Response

  @impl WorkflowCommms.MessageProvider
  def handle_callback(action, callback) do
    update_callback_message(action, callback["message_ts"])
    response = get_in(callback, ["actions", Access.at(0), "name"])
    action = put_in(action, [Access.key(:result), "response"], response)
    {:ok, action}
  end

  defp update_callback_message(action, msg_ts) do
    SlackAPI.post(
      "/chat.update",
      channel: action.meta["channel_id"],
      ts: msg_ts,
      text: action.meta["confirmation_text"],
      attachments: nil
    )
    |> check_response()
    |> case do
      :ok ->
        :ok

      {:error, error} ->
        Logger.error("Failed to update callback message: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl WorkflowCommms.MessageProvider
  def handle_action(action = %Action{type: "notify"}) do
    SlackAPI.post(
      "/chat.postMessage",
      channel: action.meta["channel_id"],
      token: Env.get!(:workflow_comms, :slack_token),
      text: action.meta["text"]
    )
    |> process_response()
  end

  @impl WorkflowCommms.MessageProvider
  def handle_action(action = %Action{type: "confirm"}) do
    SlackAPI.post(
      "/chat.postMessage",
      channel: action.meta["channel_id"],
      token: Env.get!(:workflow_comms, :slack_token),
      attachments:
        Poison.encode!([
          %{
            title: action.meta["text"],
            color: "good",
            fields: [
              %{
                title: "Name",
                value: action.action["GITHUB_WORKFLOW"],
                short: true
              },
              %{
                title: "Repository",
                value: action.action["GITHUB_REPOSITORY"],
                short: true
              },
              %{
                title: "Event",
                value: action.action["GITHUB_EVENT_NAME"],
                short: true
              },
              %{
                title: "Commit",
                value:
                  "https://github.com/#{action.action["GITHUB_REPOSITORY"]}/commit/#{
                    action.action["GITHUB_SHA"]
                  }"
              },
              %{
                title: "Workflow",
                value:
                  "https://github.com/#{action.action["GITHUB_REPOSITORY"]}/blob/#{
                    action.action["GITHUB_SHA"]
                  }/.github/main.workflow"
              }
            ]
          },
          %{
            color: "warning",
            fallback: "Confirmation request failed.",
            callback_id: action.id,
            actions: [
              %{
                name: "cancel",
                text: "Cancel Workflow",
                type: "button"
              },
              %{
                name: "confirm",
                text: "Continue Workflow",
                style: "danger",
                type: "button",
                confirm: %{
                  title: "Continue Workflow",
                  text: "Are you sure you want to continue this workflow?",
                  ok_text: "Continue Workflow",
                  dismiss_text: "Do Not Continue Workflow"
                }
              }
            ]
          }
        ])
    )
    |> process_response
  end

  def handle(_action), do: {:error, :no_handler_defined}

  defp process_response(response) do
    response
    |> check_response()
    |> case do
      :ok ->
        :ok

      {:error, error} ->
        Logger.error("Failed Slack API request: #{inspect(error)}")
        {:error, error}
    end
  end

  defp check_response({:ok, %Response{status_code: code}}) when code != 200,
    do: {:error, :non_200_response}

  defp check_response({:ok, %Response{body: %{"ok" => true}}}), do: :ok
  defp check_response({:ok, %Response{body: %{"ok" => false}} = response}), do: {:error, response}
  defp check_response({:error, error}), do: {:error, error}
end
