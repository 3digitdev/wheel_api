defmodule WheelApi.BaseRouter do
  use Plug.Router
  use Plug.ErrorHandler

  import WheelApi.Validation

  require Logger

  # Order of Plugs matters.  In this way, we ensure that we only do other Parsing etc IF there is a route match!
  plug :match
  plug CORSPlug
  plug ApiKeyPlug
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
    send_resp(conn, 404, error_response("That endpoint does not exist or that method is not supported"))
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    # TODO:  REMOVE DEBUGGING LINES
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    case reason do
      %Ecto.ChangeError{message: msg} ->
        send_resp(conn, 400, error_response(msg))
      %Plug.Parsers.ParseError{exception: %Poison.SyntaxError{message: msg}} ->
        send_resp(conn, 400, error_response("Invalid JSON: '#{msg}'"))
      %Plug.Conn.InvalidHeaderError{} ->
        send_resp(conn, 401, "")
      %{message: msg} -> send_resp(conn, 500, error_response(msg))
      _ -> send_resp(conn, 500, error_response("Something unknown went wrong"))
    end
  end
end
