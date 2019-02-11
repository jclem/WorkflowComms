defmodule SlackConfirmWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:slack_confirm_web, :port)

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: SlackConfirmWeb.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: SlackConfirmWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
