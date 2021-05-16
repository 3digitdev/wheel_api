use Mix.Config

config :wheel_api, WheelApi.Repo,
    database: System.get_env("WHEEL_API_DB_NAME"),
    username: System.get_env("WHEEL_API_DB_USER"),
    password: System.get_env("WHEEL_API_DB_PASS"),
    hostname: System.get_env("WHEEL_API_DB_HOST")

config :wheel_api,
    ecto_repos: [WheelApi.Repo],
    cowboy_port: 4000

# THIS NEEDS TO STAY AT THE BOTTOM
import_config "#{Mix.env()}.exs"
