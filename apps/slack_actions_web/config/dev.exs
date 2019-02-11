use Mix.Config

config :slack_actions_web,
  port:
    (if port = System.get_env("PORT") do
       String.to_integer(port)
     else
       4000
     end)
