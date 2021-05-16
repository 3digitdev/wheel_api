defmodule WheelApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {WheelApi.Repo, []},
      {Plug.Cowboy, scheme: :http, plug: WheelApi.BaseRouter, options: [port: cowboy_port()]}
    ]
    opts = [strategy: :one_for_one, name: WheelApi.Supervisor]

    Logger.info("Starting Application...")
    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:wheel_api, :cowboy_port, 8080)


  # TODO:  FROM https://blog.lelonek.me/minimal-elixir-http2-server-64188d0c1f3a
  # def start(_type, _args) do
  #   children = [
  #     WheelApi.Endpoint
  #     # Starts a worker by calling: WheelApi.Worker.start_link(arg)
  #     # {WheelApi.Worker, arg}
  #   ]

  #   # See https://hexdocs.pm/elixir/Supervisor.html
  #   # for other strategies and supported options
  #   opts = [strategy: :one_for_one, name: WheelApi.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end
end
