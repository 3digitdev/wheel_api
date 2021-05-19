defmodule WheelApi.Share do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias WheelApi.Repo, as: DB
    alias WheelApi.Wheel

    schema "shares" do
        field :quantity, :integer
        field :cost, :float
        field :sale_date, :date
        field :action, :string
        belongs_to :wheel, Wheel
    end

    def changeset(share, params) do
        share
            |> cast(params, [:quantity, :cost, :sale_date, :action])
            |> validate_required([:quantity, :cost, :sale_date, :action], message: "must be provided in body")
            |> validate_format(:action, ~r/(?:BUY|SELL)/, message: "must be either 'BUY' or 'SELL'")
            |> validate_number(:quantity, greater_than: 0, message: "must be > 0")
            |> validate_number(:cost, greater_than: 0.0, message: "must be > 0.0")
    end

    @spec as_map(%WheelApi.Share{}) :: map()
    def as_map(share) do
        %{
            id: share.id,
            quantity: share.quantity,
            cost: share.cost,
            sale_date: share.sale_date,
            action: share.action,
            wheel_id: share.wheel_id
        }
    end

    @spec from_map(map(), pos_integer()) :: %WheelApi.Share{}
    def from_map(map, id) do
        %WheelApi.Share{
            id: id,
            quantity: Map.get(map, "quantity"),
            cost: Map.get(map, "cost"),
            sale_date: Map.get(map, "sale_date"),
            action: Map.get(map, "action"),
            wheel_id: Map.get(map, "wheel_id")
        }
    end

    @spec as_list([%WheelApi.Share{}]) :: [map()]
    def as_list(shares), do: shares |> Enum.map(&(as_map(&1)))

    @spec exists?(pos_integer()) :: boolean
    def exists?(share_id) do
        DB.exists?(from s in WheelApi.Share, where: s.id == ^share_id)
    end

    @spec get_all(pos_integer(), pos_integer()) :: [%WheelApi.Share{}]
    def get_all(wheel_id, limit) do
        if Wheel.exists?(wheel_id) do
            {:ok, (from share in WheelApi.Share, limit: ^limit) |> DB.all |> as_list}
        else
            {:error, "no wheel"}
        end
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Share{}]
    def get_all(wheel_id) do
        if Wheel.exists?(wheel_id) do
            {:ok, (from share in WheelApi.Share) |> DB.all |> as_list}
        else
            {:error, "no wheel"}
        end
    end

    @spec get_single(pos_integer(), pos_integer()) :: {:ok, %WheelApi.Share{}} | {:error, String.t()}
    def get_single(share_id, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.get WheelApi.Share, share_id do
                :nil -> {:error, "not found"}
                share ->
                    if share.wheel_id == wheel_id do
                        {:ok, as_map(share)}
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
        case WheelApi.Share.get_single(id, wheel_id) do
            {:error, err} ->
                case err do
                    "not found" -> :ok
                    _ -> :error
                end
            {:ok, share} -> share |> from_map(id) |> DB.delete; :ok
        end
    end

    @spec create(%WheelApi.Share{}, pos_integer()) :: {:ok, map()} | {:error, String.t()}
    def create(share, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.insert share do
                {:ok, share_struct} -> {:ok, as_map(share_struct)}
                {:error, _} -> {:error, "db"}
            end
        else
            {:error, "no wheel"}
        end
    end

    @spec update(%WheelApi.Share{}, pos_integer(), pos_integer()) :: {:ok, map()} | {:error, String.t()}
    def update(new_share, share_id, wheel_id) do
        if Wheel.exists?(wheel_id) do
            case DB.get WheelApi.Share, share_id do
                :nil -> {:error, "not found"}
                share ->
                    if share.wheel_id != wheel_id do
                        {:error, "not this wheel"}
                    else
                        share
                            |> change(as_map(new_share))
                            # Add the ID back into the changeset since it's required and won't be passed in the PUT body
                            |> put_change(:id, share_id)
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
