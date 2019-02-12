# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: System.get_env("COOKIE"))
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: System.get_env("COOKIE"))
end

release :slack_actions do
  set(version: "0.1.0")

  set(
    applications: [
      :runtime_tools,
      slack_actions: :permanent,
      slack_actions_web: :permanent
    ]
  )
end
