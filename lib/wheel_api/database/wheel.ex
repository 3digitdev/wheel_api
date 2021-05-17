defmodule WheelApi.Wheel do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset, only: [validate_required: 2, cast: 3]

    alias WheelApi.Repo, as: DB

    schema "wheels" do
        field :ticker, :string
        field :description, :string
        field :subtotal, :float, default: 0.0
        field :positions_closed, :boolean, default: true
        field :assigned_shares, :boolean, default: false
        has_many :options, WheelApi.Option
        has_many :shares, WheelApi.Share
    end

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

    def as_list(wheels), do: wheels |> Enum.map(&(as_map(&1)))

    @spec exists?(pos_integer()) :: boolean
    def exists?(wheel_id) do
        DB.exists?(from w in WheelApi.Wheel, where: w.id == ^wheel_id)
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Wheel{}]
    def get_all(limit), do: (from share in WheelApi.Wheel, limit: ^limit) |> DB.all |> as_list

    @spec get_all() :: [%WheelApi.Wheel{}]
    def get_all, do: (from share in WheelApi.Wheel) |> DB.all |> as_list

    @spec get_single(pos_integer()) :: {:ok, %WheelApi.Wheel{}} | :error
    def get_single(id) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :error
            share -> {:ok, as_map(share)}
        end
    end

    @spec delete(pos_integer()) :: :ok
    def delete(id) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :ok
            share -> DB.delete(share); :ok
        end
    end

    @spec create(String.t(), String.t()) :: {:ok, %WheelApi.Wheel{}} | :error
    def create(ticker, description \\ "") do
        case DB.insert %WheelApi.Wheel{
            ticker: ticker,
            description: description,
            subtotal: 0.0,
            positions_closed: true,
            assigned_shares: false
        } do
            {:ok, struct} -> {:ok, as_map(struct)}
            {:error, _} -> :error
        end
    end

    def update(id, new_wheel) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :error
            wheel ->
                req_fields = [:ticker, :description, :subtotal, :positions_closed, :assigned_shares]
                wheel
                |> cast(as_map(new_wheel), req_fields)
                |> validate_required(req_fields)
                |> case do
                    %{valid?: false, errors: err} -> raise %KeyError{key: err |> Keyword.keys |> List.first}
                    changeset ->
                        changeset
                        |> DB.update
                        |> case do
                            {:error, _} -> :error
                            {:ok, updated} -> {:ok, as_map(updated)}
                        end
                end
        end
    end
end
