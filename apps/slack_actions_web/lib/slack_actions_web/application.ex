defmodule SlackActionsWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Env.get!(:slack_actions_web, :port) |> String.to_integer()

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: SlackActionsWeb.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: SlackActionsWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
