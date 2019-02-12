#!/usr/bin/env ruby

require "json"
require "net/http"
require "securerandom"

class ActionConfirmation
  def initialize(msg_text)
    @callback_id = SecureRandom.uuid
    @msg_text = msg_text
  end

  def confirm!
    post_message
    poll_response
  end

  private def check_response
    uri = URI("#{ENV["SLACK_ACTIONS_URL"]}/callbacks/#{@callback_id}")
    resp = Net::HTTP.get(uri)
    body = JSON.parse(resp)
    body.dig("actions", 0, "name")
  end

  private def poll_response
    retries = 12

    while retries > 0
      puts "Polling for user response (#{retries} attempts remain)."

      user_response = check_response

      if user_response == "confirm"
        puts 'Got a "confirm" response, continuing workflow.'
        exit
      end

      if user_response == "cancel"
        puts 'Got a "cancel" response, halting workflow.'
        exit 1
      end

      sleep 5

      retries -= 1
    end

    puts "Got no response, canceling workflow."
    exit 78
  end

  private def post_message
    uri = URI("https://slack.com/api/chat.postMessage")

    resp = Net::HTTP.post_form(uri, {
      channel: ENV["SLACK_BOT_CHANNEL"],
      text: @msg_text,
      token: ENV["SLACK_BOT_TOKEN"],
      attachments: [
        {
          text: "Choose 'Yes' to continue or 'Cancel' to cancel.",
          fallback: "Confirmation request failed.",
          callback_id: @callback_id,
          actions: [
            {
              name: "cancel",
              text: "Cancel",
              type: "button",
            },
            {
              name: "confirm",
              text: "Yes",
              style: "danger",
              type: "button",
            },
          ],
        },
      ].to_json,
    })

    unless JSON.load(resp.body)["ok"]
      raise "Non-ok response from Slack"
    end
  end
end

ActionConfirmation.new(ARGV.join(" ")).confirm!
