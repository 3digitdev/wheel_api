defmodule WheelApi.Wheel do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias WheelApi.Repo, as: DB

    schema "wheels" do
        field :ticker, :string
        field :description, :string, default: ""
        field :subtotal, :float, default: 0.0
        field :positions_closed, :boolean, default: true
        field :assigned_shares, :boolean, default: false
        has_many :options, WheelApi.Option
        has_many :shares, WheelApi.Share
    end

    def changeset(wheel, params) do
        wheel
            |> cast(params, [:ticker, :description, :subtotal, :positions_closed, :assigned_shares])
            |> validate_required([:ticker], message: "must be provided in body")
            |> validate_format(:ticker, ~r/[A-Z0-9\-]*/, message: "must be capital letters or numbers with '-'")
            |> validate_number(:subtotal, greater_than_or_equal_to: 0.0, message: "must not be negative")
    end

    @spec from_map(map(), pos_integer()) :: %WheelApi.Wheel{}
    def from_map(map, id) do
        %WheelApi.Wheel{
            id: id,
            ticker: Map.get(map, "ticker"),
            description: Map.get(map, "description"),
            subtotal: Map.get(map, "subtotal"),
            positions_closed: Map.get(map, "positions_closed"),
            assigned_shares: Map.get(map, "assigned_shares")
        }
    end

    @spec as_map(%WheelApi.Wheel{}) :: map()
    def as_map(wheel) do
        %{
            id: wheel.id,
            ticker: wheel.ticker,
            description: wheel.description,
            subtotal: wheel.subtotal,
            positions_closed: wheel.positions_closed,
            assigned_shares: wheel.assigned_shares
        }
    end

    @spec as_list([%WheelApi.Wheel{}]) :: [map()]
    def as_list(wheels), do: wheels |> Enum.map(&(as_map(&1)))

    @spec exists?(pos_integer()) :: boolean
    def exists?(wheel_id) do
        DB.exists?(from w in WheelApi.Wheel, where: w.id == ^wheel_id)
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Wheel{}]
    def get_all(limit), do: (from wheel in WheelApi.Wheel, limit: ^limit) |> DB.all |> as_list

    @spec get_all() :: [%WheelApi.Wheel{}]
    def get_all, do: (from wheel in WheelApi.Wheel) |> DB.all |> as_list

    @spec get_single(pos_integer()) :: {:ok, %WheelApi.Wheel{}} | :error
    def get_single(id) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :error
            wheel -> {:ok, as_map(wheel)}
        end
    end

    @spec delete(pos_integer()) :: :ok
    def delete(id) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :ok
            wheel -> DB.delete(wheel); :ok
        end
    end

    @spec create(%WheelApi.Wheel{}) :: {:ok, map()} | :error
    def create(wheel) do
        case DB.insert wheel do
            {:ok, wheel_struct} -> {:ok, as_map(wheel_struct)}
            {:error, _} -> :error
        end
    end

    @spec update(%WheelApi.Wheel{}, pos_integer()) :: {:ok, map()} | {:error, String.t()}
    def update(new_wheel, wheel_id) do
        case DB.get WheelApi.Wheel, wheel_id do
            :nil -> {:error, "not found"}
            wheel ->
                wheel
                    |> change(as_map(new_wheel))
                    # Add the ID back into the changeset since it's required and won't be passed in the PUT body
                    |> put_change(:id, wheel_id)
                    |> DB.update
                    |> case do
                        {:error, _} -> {:error, "db"}
                        {:ok, updated} -> {:ok, as_map(updated)}
                    end
        end
    end
end
