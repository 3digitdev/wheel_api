defmodule WheelApi.BaseRouter do
  use Plug.Router
  use Plug.ErrorHandler

  require Logger

  # Order of Plugs matters.  In this way, we ensure that we only do other Parsing etc IF there is a route match!
  plug :match
  # Here we tell it to run all requests through these Plugs BEFORE we hit the routers below
  plug Plug.Logger
  plug Plug.Parsers,
       parsers: [:json],
       pass: ["application/json"],
       json_decoder: Poison
  # Finally, we send the Plug.Conn to the function that matches the endpoint path
  plug :dispatch

  forward "/wheels", to: WheelApi.Router.WheelRouter

  match _ do
    send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    case reason do
      %Ecto.ChangeError{message: msg} -> send_resp(conn, 400, Poison.encode!(%{error: msg}))
      %{message: msg} -> send_resp(conn, 500, Poison.encode!(%{error: msg}))
      _ -> send_resp(conn, 500, Poison.encode!(%{error: "ERROR: Something went wrong!"}))
    end
  end
end
