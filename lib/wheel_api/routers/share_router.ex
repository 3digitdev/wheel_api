defmodule WheelApi.Router.ShareRouter do
    use Plug.Router

    import WheelApi.Validation
    import Ecto.Changeset

    require Logger

    plug :match
    plug :dispatch

    defp parse_body(conn, success_fn) do
        %WheelApi.Share{}
            |> WheelApi.Share.changeset(conn.body_params)
            |> changeset_to_error_list
            |> case do
                {:ok, changeset}  -> success_fn.(changeset)
                {:error, errors} -> send_resp(conn, 400, error_response(errors))
            end
    end

    get "/" do
        shares = case conn.params |> Map.get("limit") do
            :nil -> WheelApi.Share.get_all
            limit -> WheelApi.Share.get_all limit
        end
        send_resp(conn, 200, success_response(shares, "shares"))
    end

    post "/" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        conn
            |> parse_body(fn changeset ->
                case changeset
                    |> put_change(:wheel_id, wheel_id)
                    |> apply_changes
                    |> WheelApi.Share.create(wheel_id)
                do
                    {:ok, share} -> send_resp(conn, 201, success_response(share, "share"))
                    {:error, err} ->
                        case err do
                            "no wheel" -> send_resp(conn, 404, error_response("Wheel #{wheel_id} not found"))
                            "db" -> send_resp(conn, 500, error_response("DB failure on Share creation"))
                            _ -> send_resp(conn, 500, error_response("Unknown failure on Share creation"))
                        end
                end
            end)
    end

    get "/:share_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        share_id = String.to_integer(share_id)
        case WheelApi.Share.get_single(share_id, wheel_id) do
            {:ok, share} -> send_resp(conn, 200, success_response(share, "share"))
            {:error, err} ->
                case err do
                    "not found" -> send_resp(conn, 404, error_response("Share '#{share_id}' not found"))
                    "no wheel" -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
                    "not this wheel" -> send_resp(conn, 400, error_response("Share '#{share_id} not in Wheel '#{wheel_id}'"))
                    _ -> send_resp(conn, 500, error_response("Unknown failure on Share retrieval"))
                end
        end
    end

    put "/:share_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        share_id = String.to_integer(share_id)
        parse_body(conn, fn changeset ->
            case changeset |> apply_changes |> WheelApi.Share.update(share_id, wheel_id) do
                {:ok, wheel} -> send_resp(conn, 200, success_response(wheel, "wheel"))
                {:error, err} ->
                    case err do
                        "not found" -> send_resp(conn, 404, error_response("Share '#{share_id}' not found"))
                        "db" -> send_resp(conn, 500, error_response("DB failure on Share update"))
                        "no wheel" -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
                        "not this wheel" -> send_resp(conn, 400, error_response("Share '#{share_id} not in Wheel '#{wheel_id}'"))
                        _ -> send_resp(conn, 500, error_response("Unknown failure on Share update"))
                    end
            end
        end)
    end

    delete "/:share_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        share_id = String.to_integer(share_id)
        case WheelApi.Share.delete(share_id, wheel_id) do
            :error -> send_resp(conn, 404, error_response("Invalid wheel"))
            :ok -> send_resp(conn, 204, "")
        end
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
