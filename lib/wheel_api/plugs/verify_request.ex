defmodule WheelApi.Plug.VerifyRequest do
    defmodule IncompleteRequestError do
        @moduledoc """
        Error raised when a required field is missing
        """

        defexception message: "", plug_status: 400
    end

    def init(options), do: options

    def call(%Plug.Conn{request_path: path} = conn, opts) do
        # Only apply this Plug if the path for the request is within our :path options for the Plug
        if path in opts[:paths], do: verify_request!(conn.params, opts[:fields])
        # Always return the connection from `call/2`
        conn
    end

    defp verify_request!(params, fields) do
        verified = params
            |> Map.keys()
            |> contains_fields?(fields)

        unless verified, do: raise(IncompleteRequestError)
    end

    defp contains_fields?(keys, fields), do: Enum.all?(fields, &(&1 in keys))
end
