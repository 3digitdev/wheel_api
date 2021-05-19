defmodule WheelApi.Router.OptionRouter do
    use Plug.Router

    import WheelApi.Validation
    import Ecto.Changeset

    require Logger

    plug :match
    plug :dispatch

    defp parse_body(conn, success_fn) do
        %WheelApi.Option{}
            |> WheelApi.Option.changeset(conn.body_params)
            |> changeset_to_error_list
            |> case do
                {:ok, changeset}  -> success_fn.(changeset)
                {:error, errors} -> send_resp(conn, 400, error_response(errors))
            end
    end

    get "/" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        result = case conn.params |> Map.get("limit") do
            :nil -> WheelApi.Option.get_all(wheel_id)
            limit -> WheelApi.Option.get_all(wheel_id, limit)
        end
        case result do
            {:ok, options} -> send_resp(conn, 200, success_response(options, "options"))
            {:error, err} ->
                case err do
                    "no wheel" -> send_resp(conn, 404, error_response("Wheel #{wheel_id} not found"))
                    _ -> send_resp(conn, 500, error_response("Unknown failure on Option list"))
                end
        end
    end

    post "/" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        conn
            |> parse_body(fn changeset ->
                case changeset
                    |> put_change(:wheel_id, wheel_id)
                    |> apply_changes
                    |> WheelApi.Option.create(wheel_id)
                do
                    {:ok, option} -> send_resp(conn, 201, success_response(option, "option"))
                    {:error, err} ->
                        case err do
                            "no wheel" -> send_resp(conn, 404, error_response("Wheel #{wheel_id} not found"))
                            "db" -> send_resp(conn, 500, error_response("DB failure on Option creation"))
                            _ -> send_resp(conn, 500, error_response("Unknown failure on Option creation"))
                        end
                end
            end)
    end

    get "/:option_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        option_id = String.to_integer(option_id)
        case WheelApi.Option.get_single(option_id, wheel_id) do
            {:ok, option} -> send_resp(conn, 200, success_response(option, "option"))
            {:error, err} ->
                case err do
                    "not found" -> send_resp(conn, 404, error_response("Option '#{option_id}' not found"))
                    "no wheel" -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
                    "not this wheel" -> send_resp(conn, 400, error_response("Option '#{option_id} not in Wheel '#{wheel_id}'"))
                    _ -> send_resp(conn, 500, error_response("Unknown failure on Option retrieval"))
                end
        end
    end

    put "/:option_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        option_id = String.to_integer(option_id)
        parse_body(conn, fn changeset ->
            case changeset |> apply_changes |> WheelApi.Option.update(option_id, wheel_id) do
                {:ok, wheel} -> send_resp(conn, 200, success_response(wheel, "wheel"))
                {:error, err} ->
                    case err do
                        "not found" -> send_resp(conn, 404, error_response("Option '#{option_id}' not found"))
                        "db" -> send_resp(conn, 500, error_response("DB failure on Option update"))
                        "no wheel" -> send_resp(conn, 404, error_response("Wheel '#{wheel_id}' not found"))
                        "not this wheel" -> send_resp(conn, 400, error_response("Option '#{option_id} not in Wheel '#{wheel_id}'"))
                        _ -> send_resp(conn, 500, error_response("Unknown failure on Option update"))
                    end
            end
        end)
    end

    delete "/:option_id" do
        wheel_id = String.to_integer(conn.params["wheel_id"])
        option_id = String.to_integer(option_id)
        case WheelApi.Option.delete(option_id, wheel_id) do
            :error -> send_resp(conn, 404, error_response("Invalid wheel"))
            :ok -> send_resp(conn, 204, "")
        end
    end

    match _ do
        send_resp(conn, 404, "That endpoint does not exist or that method is not supported")
    end
end
