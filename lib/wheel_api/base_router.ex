defmodule WheelApi.BaseRouter do
  use Plug.Router
  use Plug.ErrorHandler

  alias WheelApi.Plug.LogBody
  alias WheelApi.Plug.VerifyRequest
  alias WheelApi.Router.UserRouter

  require Logger

  # Order of Plugs matters.  In this way, we ensure that we only do other Parsing etc IF there is a route match!
  plug :match
  plug Plug.Logger
  plug Plug.Parsers,
       parsers: [:json],
       pass: ["application/json"],
       json_decoder: Poison
  # Here we tell it to run all requests through this Plug BEFORE we hit the routers below
  plug LogBody, fields: ["content-type", "application/json"], paths: ["/test"]
  plug Plug.Parsers, parsers: [:url_encoded, :mimetype]
  plug VerifyRequest, fields: ["content", "mimetype"], paths: ["/upload"]
  # Finally, we send the Plug.Conn to the function that matches the endpoint path
  plug :dispatch

  forward "/users", to: UserRouter

  get "/" do
    send_resp(conn, 200, "Welcome\n")
  end

  get "/upload" do
    send_resp(conn, 201, "Uploaded\n")
  end

  post "/test/:id" do
    Logger.info("Received /test endpoint call for ID ##{id}")
    send_resp(conn, 200, "Thanks @ #{conn.params["id"]}\n")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    send_resp(conn, conn.status, "ERROR: Something went wrong!")
  end
end
