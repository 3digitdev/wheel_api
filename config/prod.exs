use Mix.Config

config :wheel_api, WheelApi.Endpoint, 
  port: ("PORT" || "4444") 
    |> System.get_env 
    |> String.to_integer