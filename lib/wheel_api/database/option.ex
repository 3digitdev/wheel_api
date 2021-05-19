defmodule WheelApi.Option do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias WheelApi.Repo, as: DB
    alias WheelApi.Wheel

    schema "options" do
        field :type, :string
        field :action, :string
        field :strike, :float
        field :quantity, :integer, default: 1
        field :premium, :float
        field :open, :boolean, default: true
        field :sale_date, :date
        field :exp_date, :date
        belongs_to :wheel, Wheel
    end

    def changeset(option, params) do
        option
            |> cast(params, [:type, :action, :strike, :quantity, :premium, :open, :sale_date, :exp_date])
            |> validate_required(
                [:type, :action, :strike, :premium, :sale_date, :exp_date], message: "must be provided in body"
            )
            |> validate_format(:type, ~r/(?:CALL|PUT)/, message: "must be either 'CALL' or 'PUT'")
            |> validate_format(:action, ~r/(?:BUY|SELL)/, message: "must be either 'BUY' or 'SELL'")
            |> validate_number(:quantity, greater_than: 0, message: "must be > 0")
            |> validate_number(:strike, greater_than: 0.0, message: "must be > 0.0")
            |> validate_number(:premium, greater_than: 0.0, message: "must be > 0.0")
    end

    @spec as_map(%WheelApi.Option{}) :: map()
    def as_map(option) do
        %{
            id: option.id,
            type: option.type,
            action: option.action,
            strike: option.strike,
            quantity: option.quantity,
            premium: option.premium,
            open: option.open,
            sale_date: option.sale_date,
            exp_date: option.exp_date,
            wheel_id: option.wheel_id
        }
    end

    @spec from_map(map(), pos_integer()) :: %WheelApi.Option{}
    def from_map(map, id) do
        %WheelApi.Option{
            id: id,
            type: Map.get(map, "type"),
            action: Map.get(map, "action"),
            strike: Map.get(map, "strike"),
            quantity: Map.get(map, "quantity"),
            premium: Map.get(map, "premium"),
            open: Map.get(map, "open"),
            sale_date: Map.get(map, "sale_date"),
            exp_date: Map.get(map, "exp_date"),
            wheel_id: Map.get(map, "wheel_id")
        }
    end

    @spec as_list([%WheelApi.Option{}]) :: [map()]
    def as_list(options), do: options |> Enum.map(&(as_map(&1)))

    @spec exists?(pos_integer()) :: boolean
    def exists?(option_id) do
        DB.exists?(from o in WheelApi.Option, where: o.id == ^option_id)
    end

    @spec get_all(pos_integer(), pos_integer()) :: [%WheelApi.Option{}]
    def get_all(wheel_id, limit) do
        if Wheel.exists?(wheel_id) do
            {:ok, (from option in WheelApi.Option, limit: ^limit) |> DB.all |> as_list}
        else
            {:error, "no wheel"}
        end
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Option{}]
    def get_all(wheel_id) do
        if Wheel.exists?(wheel_id) do
            {:ok, (from option in WheelApi.Option) |> DB.all |> as_list}
        else
            {:error, "no wheel"}
        end
    end

    @spec get_single(pos_integer(), pos_integer()) :: {:ok, %WheelApi.Option{}} | {:error, String.t()}
    def get_single(option_id, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.get WheelApi.Option, option_id do
                :nil -> {:error, "not found"}
                option ->
                    if option.wheel_id == wheel_id do
                        {:ok, as_map(option)}
                    else
                        {:error, "not this wheel"}
                    end
            end
        else
            {:error, "no wheel"}
        end
    end

    @spec delete(pos_integer(), pos_integer()) :: :ok | :error
    def delete(id, wheel_id) do
        case WheelApi.Option.get_single(id, wheel_id) do
            {:error, err} ->
                case err do
                    "not found" -> :ok
                    _ -> :error
                end
            {:ok, option} -> option |> from_map(id) |> DB.delete; :ok
        end
    end

    @spec create(%WheelApi.Option{}, pos_integer()) :: {:ok, map()} | {:error, String.t()}
    def create(option, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.insert option do
                {:ok, option_struct} -> {:ok, as_map(option_struct)}
                {:error, _} -> {:error, "db"}
            end
        else
            {:error, "no wheel"}
        end
    end

    @spec update(%WheelApi.Option{}, pos_integer(), pos_integer()) :: {:ok, map()} | {:error, String.t()}
    def update(new_option, option_id, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.get WheelApi.Option, option_id do
                :nil -> {:error, "not found"}
                option ->
                    if option.wheel_id != wheel_id do
                        {:error, "not this wheel"}
                    else
                        option
                            |> change(as_map(new_option))
                            # Add the ID back into the changeset since it's required and won't be passed in the PUT body
                            |> put_change(:id, option_id)
                            |> put_change(:wheel_id, wheel_id)
                            |> DB.update
                            |> case do
                                {:error, _} -> {:error, "db"}
                                {:ok, updated} -> {:ok, as_map(updated)}
                            end
                    end
            end
        else
            {:error, "no wheel"}
        end
    end
end
