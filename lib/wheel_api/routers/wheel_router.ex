defmodule WheelApi.Router.WheelRouter do
    use Plug.Router

    require Logger

    plug :match
    plug :dispatch

    forward "/:wheel_id/shares", to: WheelApi.Router.ShareRouter
    forward "/:wheel_id/options", to: WheelApi.Router.OptionRouter

    get "/" do
        wheels = case conn.params |> Map.get("limit") do
            :nil -> WheelApi.Wheel.get_all
            limit -> WheelApi.Wheel.get_all limit
        end
        send_resp(conn, 200, Poison.encode!(%{wheels: wheels}))
    end

    post "/" do
        body = conn.body_params
        case Map.get(body, "ticker") do
            :nil -> send_resp(conn, 400, Poison.encode!(%{error: "You must provide a 'ticker' for the Wheel"}))
            "" -> send_resp(conn, 400, Poison.encode!(%{error: "You must provide a 'ticker' for the Wheel"}))
            ticker ->
                case WheelApi.Wheel.create(ticker, Map.get(body, "description", "")) do
                    {:ok, wheel} -> send_resp(conn, 201, Poison.encode!(%{wheel: wheel}))
                    :error -> send_resp(conn, 400, Poison.encode!(%{error: "Invalid body format"}))
                end
        end
    end

    get "/:wheel_id" do
        case WheelApi.Wheel.get_single(wheel_id) do
            :error -> send_resp(conn, 404, Poison.encode!(%{error: "Wheel '#{wheel_id}' not found"}))
            {:ok, wheel} -> send_resp(conn, 200, Poison.encode!(%{wheel: wheel}))
        end
    end

    put "/:wheel_id" do
        try do
            if WheelApi.Wheel.exists?(wheel_id) do
                wheel = WheelApi.Wheel.from_map(conn.body_params, wheel_id)
                case WheelApi.Wheel.update(wheel_id, wheel) do
                    {:ok, updated} -> send_resp(conn, 200, Poison.encode!(%{wheel: updated}))
                    _ -> send_resp(conn, 400, Poison.encode!(%{error: "Something went wrong"}))
                end
            else
                send_resp(conn, 404, Poison.encode!(%{error: "Wheel '#{wheel_id}' not found"}))
            end
        rescue
            e in KeyError -> IO.inspect e; send_resp(conn, 400, Poison.encode!(%{error: "Missing required key '#{e.key}'"}))
        end
    end

    delete "/:wheel_id" do
        :ok = WheelApi.Wheel.delete(wheel_id)
        send_resp(conn, 204, "")
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
