defmodule WheelApi.Wheel do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset, only: [change: 2]

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

    @spec exists?(pos_integer()) :: boolean
    def exists?(wheel_id) do
        DB.exists?(from w in WheelApi.Wheel, where: w.id == ^wheel_id)
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Wheel{}]
    def get_all(limit), do: DB.all from share in WheelApi.Wheel, limit: ^limit

    @spec get_all() :: [%WheelApi.Wheel{}]
    def get_all, do: DB.all from share in WheelApi.Wheel

    @spec get_single(pos_integer()) :: {:ok, %WheelApi.Wheel{}} | :error
    def get_single(id) do
        case DB.get WheelApi.Wheel, id do
            :nil -> :error
            share -> {:ok, share}
        end
    end

    @spec delete(pos_integer()) :: :ok
    def delete(id) do
        case WheelApi.Wheel.get_single(id) do
            :error -> :ok
            {:ok, share} -> DB.delete share; :ok
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
            {:ok, struct} -> {:ok, struct}
            {:error, _} -> :error
        end
    end

    def update(new_wheel) do
        case WheelApi.Wheel.get_single(new_wheel.id) do
            :error -> :error
            {:ok, wheel} ->
                changeset = change(
                    wheel,
                    ticker: new_wheel.ticker,
                    description: new_wheel.description,
                    subtotal: new_wheel.subtotal,
                    positions_closed: new_wheel.positions_closed,
                    assigned_shares: new_wheel.assigned_shares
                )
                case DB.update(changeset) do
                    {:error, _} -> :error
                    success -> success
                end
        end
    end
end
