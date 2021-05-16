defmodule WheelApi.Plug.LogBody do
    require Logger

    def init(options), do: options

    def call(conn, _opts) do
        Logger.info("Params:  #{inspect conn.params}")
        conn
    end
end
