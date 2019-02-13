defmodule WorkflowCommsWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Env.get!(:workflow_comms_web, :port) |> String.to_integer()

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: WorkflowCommsWeb.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: WorkflowCommsWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
