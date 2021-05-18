defmodule ApiKeyPlug do

    def init(opts), do: opts

    def call(%Plug.Conn{req_headers: headers} = conn, _opts) do
        secret_key = System.get_env("WHEEL_API_SECRET")
        case headers |> Enum.into(%{}) |> Map.get("apikey", :nil) do
            ^secret_key -> conn
            _ -> raise Plug.Conn.InvalidHeaderError
        end
    end
end
