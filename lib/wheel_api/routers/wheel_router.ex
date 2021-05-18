defmodule WheelApi.Router.WheelRouter do
    use Plug.Router

    import WheelApi.Validation
    import Ecto.Changeset

    require Logger

    plug :match
    plug :dispatch

    forward "/:wheel_id/shares", to: WheelApi.Router.ShareRouter
    forward "/:wheel_id/options", to: WheelApi.Router.OptionRouter

    defp parse_body(conn, success_fn) do
        %WheelApi.Wheel{}
            |> WheelApi.Wheel.changeset(conn.body_params)
            |> changeset_to_error_list
            |> case do
                {:ok, changeset}  -> success_fn.(changeset)
                {:error, errors} -> send_resp(conn, 400, error_response(errors))
            end
    end

    get "/" do
        wheels = case conn.params |> Map.get("limit") do
            :nil -> WheelApi.Wheel.get_all
            limit -> WheelApi.Wheel.get_all limit
        end
        send_resp(conn, 200, success_response(wheels, "wheels"))
    end

    post "/" do
        parse_body(conn, fn changeset ->
            case changeset |> apply_changes |> WheelApi.Wheel.create do
                {:ok, wheel} -> send_resp(conn, 201, success_response(wheel, "wheel"))
                :error -> send_resp(conn, 500, error_response("Unknown DB failure on Wheel creation"))
            end
        end)
    end

    get "/:wheel_id" do
        case WheelApi.Wheel.get_single(wheel_id) do
            {:ok, wheel} -> send_resp(conn, 200, success_response(wheel, "wheel"))
            :error -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
        end
    end

    put "/:wheel_id" do
        parse_body(conn, fn changeset ->
            case changeset |> apply_changes |> WheelApi.Wheel.update(String.to_integer(wheel_id)) do
                {:ok, wheel} -> send_resp(conn, 200, success_response(wheel, "wheel"))
                {:error, err} ->
                    case err do
                        "not found" -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
                        "db" -> send_resp(conn, 500, error_response("DB failure on Wheel update"))
                        _ -> send_resp(conn, 500, error_response("Unknown failure on Wheel update"))
                    end
            end
        end)
    end

    delete "/:wheel_id" do
        :ok = WheelApi.Wheel.delete(wheel_id)
        send_resp(conn, 204, "")
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
