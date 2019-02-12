use Mix.Config

config :slack_actions_web, :slack_signing_secret, {:system, "SLACK_SIGNING_SECRET"}

import_config "#{Mix.env()}.exs"
