use Mix.Config

config :workflow_comms_web,
  slack_signing_secret: {:system, "SLACK_SIGNING_SECRET"},
  twilio_sid: {:system, "TWILIO_SID"},
  twilio_token: {:system, "TWILIO_TOKEN"}

import_config "#{Mix.env()}.exs"
