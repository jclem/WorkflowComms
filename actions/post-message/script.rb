#!/usr/bin/env ruby

require "json"
require "net/http"

resp = Net::HTTP.post(
  URI("#{ENV["workflow_comms_URL"]}/actions"),
  {
    provider: ENV["MESSAGE_PROVIDER"],
    type: "notify",
    meta: {
      channel_id: ENV["SLACK_CHANNEL_ID"],
      text: ARGV.join(" "),
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

puts "=== Response from POST /actions"

pp resp
resp.each_header { |key, value| puts "#{key}: #{value}" }

begin
  pp JSON.parse(resp.body)
rescue
  pp resp.body
end

unless resp.code == "201"
  raise "Non-ok response from WorkflowComms"
end
