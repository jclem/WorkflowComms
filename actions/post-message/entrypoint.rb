#!/usr/bin/env ruby

require "json"
require "net/http"

resp = Net::HTTP.post(URI(ENV["WEBHOOK_URL"]),
                      {text: ARGV.join(" ")}.to_json,
                      "content-type" => "application/json")

if resp.body.chomp != "ok"
  raise "Received non-OK response from Slack"
end
