defmodule WheelApi.Router.UserRouter do
    use Plug.Router

    require Logger

    plug :match
    plug :dispatch

    get "/" do
        send_resp(conn, 200, "/users")
    end

    get "/:id" do
        send_resp(conn, 200, "/users/#{id}\n")
    end
end
