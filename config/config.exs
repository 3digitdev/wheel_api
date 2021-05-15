use Mix.Config

config :wheel_api, WheelApi.Endpoint, port: 4000

import_config "#{Mix.env()}.exs"