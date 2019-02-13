#!/usr/bin/env ruby

require "json"
require "net/http"
require "pp"

class ActionConfirmation
  attr_accessor :action_id

  def initialize(msg_text)
    @msg_text = msg_text
    uri = URI(ENV["WORKFLOW_COMMS_URL"])
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
  end

  def confirm!
    post_message
    poll_response
  end

  private def print_response(label, resp)
    puts "=== Response from #{label}"

    pp resp
    resp.each_header { |key, value| puts "#{key}: #{value}" }

    begin
      pp JSON.parse(resp.body)
    rescue
      pp resp.body
    end
  end

  private def check_response
    resp = @http.get("/actions/#{action_id}")
    print_response("GET /actions/:id", resp)
    body = JSON.parse(resp.body)
    body.dig("result", "response")
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
        exit 78
      end

      sleep 5

      retries -= 1
    end

    puts "Got no response, canceling workflow."
    exit 78
  end

  private def post_message
    resp = @http.post(
      "/actions",
      {
        provider: ENV["MESSAGE_PROVIDER"],
        type: "confirm",
        meta: {
          channel_id: ENV["SLACK_CHANNEL_ID"],
          text: @msg_text,
          confirmation_text: ENV["SLACK_CONFIRMATION_TEXT"] || "Thank you!",
          twilio_workflow_url: ENV["TWILIO_WORKFLOW_URL"],
          to: ENV["TWILIO_TO"],
          from: ENV["TWILIO_FROM"],
        },
        action: {
          GITHUB_WORKFLOW: ENV["GITHUB_WORKFLOW"],
          GITHUB_REPOSITORY: ENV["GITHUB_REPOSITORY"],
          GITHUB_EVENT_NAME: ENV["GITHUB_EVENT_NAME"],
          GITHUB_SHA: ENV["GITHUB_SHA"].chomp, # For act: https://github.com/nektos/act/issues/31
        },
      }.to_json,
      "content-type" => "application/json",
    )

    print_response("POST /actions", resp)

    unless resp.code == "201"
      raise "Non-ok response from WorkflowComms"
    end

    body = JSON.load(resp.body)
    self.action_id = body["id"]
  end
end

ActionConfirmation.new(ARGV.join(" ")).confirm!
