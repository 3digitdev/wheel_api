defmodule WheelApi.Router.OptionRouter do
    use Plug.Router

    require Logger

    plug :match
    plug :dispatch

    get "/" do
        send_resp(conn, 200, "GET /options")
    end

    post "/" do
       send_resp(conn, 200, "POST /options")
    end

    get "/:option_id" do
        send_resp(conn, 200, "GET /options/#{option_id}\n")
    end

    put "/:option_id" do
        send_resp(conn, 200, "PUT /options/#{option_id}\n")
    end

    delete "/:option_id" do
        send_resp(conn, 200, "DELETE /options/#{option_id}\n")
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
