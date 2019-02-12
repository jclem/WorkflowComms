defmodule SlackActions do
  @moduledoc """
  A module for storing action callbacks received by Slack and then updating
  action messages
  """

  alias SlackActions.SlackAPI

  @doc """
  Store a callback and update its Slack message.
  """
  @spec handle_callback(SlackActions.Callbacks.callback()) :: :ok | no_return
  def handle_callback(
        %{"callback_id" => cb_id, "message_ts" => msg_ts, "channel" => %{"id" => ch_id}} =
          callback
      ) do
    with SlackActions.Callbacks.put_callback(cb_id, callback),
         update_callback_message(ch_id, msg_ts) do
      :ok
    end
  end

  defp update_callback_message(ch_id, msg_ts) do
    SlackAPI.post!(
      "/chat.update",
      channel: ch_id,
      ts: msg_ts,
      text: "Thank you!",
      attachments: nil
    )
  end
end
