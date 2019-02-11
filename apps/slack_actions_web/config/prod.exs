use Mix.Config

config :slack_actions_web, port: System.get_env("PORT") |> String.to_integer()
