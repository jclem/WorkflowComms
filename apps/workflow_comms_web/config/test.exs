use Mix.Config

config :logger, level: :warn
config :workflow_comms_web, port: "0", slack_signing_secret: "signing_secret"
