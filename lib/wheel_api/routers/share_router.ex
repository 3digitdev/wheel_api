defmodule WheelApi.Router.ShareRouter do
    use Plug.Router

    require Logger

    plug :match

    plug :dispatch

    get "/" do
        shares = case conn.params |> Map.get("limit") do
            :nil -> WheelApi.Share.get_all
            limit -> WheelApi.Share.get_all limit
        end
        send_resp(conn, 200, Poison.encode!(%{shares: shares}))
    end

    post "/" do
        send_resp(conn, 200, "POST /shares")
    end

    get "/:share_id" do
        send_resp(conn, 200, "GET /shares/#{share_id}\n")
    end

    put "/:share_id" do
        send_resp(conn, 200, "PUT /shares/#{share_id}\n")
    end

    delete "/:share_id" do
        send_resp(conn, 200, "DELETE /shares/#{share_id}\n")
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
