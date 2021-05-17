defmodule WheelApi.Share do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset, only: [change: 2]

    alias WheelApi.Repo, as: DB
    alias WheelApi.Wheel

    schema "shares" do
        field :quantity, :integer, default: 0
        field :cost, :float, default: 0.0
        field :sale_date, :date
        field :action, :string
        belongs_to :wheel, Wheel
    end

    def as_map(share) do
        %{
            id: share.id,
            quantity: share.quantity,
            cost: share.cost,
            sale_date: share.sale_date,
            action: share.action
        }
    end

    def as_list(shares), do: shares |> Enum.map(&(as_map(&1)))

    @spec exists?(pos_integer()) :: boolean
    def exists?(share_id) do
        DB.exists?(from s in WheelApi.Share, where: s.id == ^share_id)
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Share{}]
    def get_all(limit), do: DB.all from share in WheelApi.Share, limit: ^limit

    @spec get_all() :: [%WheelApi.Share{}]
    def get_all, do: DB.all from share in WheelApi.Share

    @spec get_single(pos_integer()) :: {:ok, %WheelApi.Share{}} | :error
    def get_single(id) do
        case DB.get WheelApi.Share, id do
            :nil -> :error
            share -> {:ok, share}
        end
    end

    @spec delete(pos_integer()) :: :ok
    def delete(id) do
        case WheelApi.Share.get_single(id) do
            :error -> :ok
            {:ok, share} -> DB.delete share; :ok
        end
    end

    @spec create(pos_integer(), pos_integer(), float(), Ecto.Date, String.t()) :: {:ok, %WheelApi.Share{}} | :error
    def create(wheel_id, quantity, cost, sale_date, action) do
        if Wheel.exists?(wheel_id) do
            case DB.insert %WheelApi.Share{
                quantity: quantity,
                cost: cost,
                sale_date: sale_date,
                action: action,
                wheel_id: wheel_id
            } do
                {:ok, struct} -> {:ok, struct}
                {:error, e} -> IO.inspect e; :error
            end
        else
            :error
        end
    end

    def update(new_share) do
        case WheelApi.Share.get_single(new_share.id) do
            :error -> :error
            {:ok, share} ->
                changeset = change(
                    share,
                    type: new_share.type,
                    action: new_share.action,
                    strike: new_share.strike,
                    quantity: new_share.quantity,
                    premium: new_share.premium,
                    open: new_share.open,
                    sale_date: new_share.sale_date,
                    exp_date: new_share.exp_date
                )
                case DB.update(changeset) do
                    {:error, _} -> :error
                    success -> success
                end
        end
    end
end
