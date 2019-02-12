use Mix.Config

config :logger, level: :warn
config :slack_actions_web, port: "0", slack_signing_secret: "signing_secret"
