defmodule WheelApi.Option do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset, only: [change: 2]

    alias WheelApi.Repo, as: DB
    alias WheelApi.Wheel

    schema "options" do
        field :type, :string
        field :action, :string, default: "SELL"
        field :strike, :float
        field :quantity, :integer, default: 1
        field :premium, :float
        field :open, :boolean, default: true
        field :sale_date, :date
        field :exp_date, :date
        belongs_to :wheel, Wheel
    end

    @spec exists?(pos_integer()) :: boolean
    def exists?(option_id) do
        DB.exists?(from o in WheelApi.Option, where: o.id == ^option_id)
    end

    @spec get_all(pos_integer()) :: [%WheelApi.Option{}]
    def get_all(limit), do: DB.all from option in WheelApi.Option, limit: ^limit

    @spec get_all() :: [%WheelApi.Option{}]
    def get_all, do: DB.all from option in WheelApi.Option

    @spec get_single(pos_integer()) :: {:ok, %WheelApi.Option{}} | :error
    def get_single(id) do
        case DB.get WheelApi.Option, id do
            :nil -> :error
            option -> {:ok, option}
        end
    end

    @spec create(
        pos_integer(), String.t(), String.t(), float(), float(), Ecto.Date, Ecto.Date, pos_integer(), boolean()
    ) :: {:ok, %WheelApi.Option{}} | :error
    def create(wheel_id, type, action, strike, premium, sale_date, exp_date, quantity \\ 1, open \\ true) do
        if Wheel.exists?(wheel_id) do
            case DB.insert %WheelApi.Option{
                type: type,
                action: action,
                strike: strike,
                quantity: quantity,
                premium: premium,
                open: open,
                sale_date: sale_date,
                exp_date: exp_date,
                wheel_id: wheel_id
            } do
                {:ok, struct} -> {:ok, struct}
                {:error, _} -> :error
            end
        else
            :error
        end
    end

    @spec update(%WheelApi.Option{}) :: {:ok, %WheelApi.Option{}} | :error
    def update(new_option) do
        case WheelApi.Option.get_single(new_option.id) do
            :error -> :error
            {:ok, option} ->
                changeset = change(
                    option,
                    type: new_option.type,
                    action: new_option.action,
                    strike: new_option.strike,
                    quantity: new_option.quantity,
                    premium: new_option.premium,
                    open: new_option.open,
                    sale_date: new_option.sale_date,
                    exp_date: new_option.exp_date
                )
                case DB.update(changeset) do
                    {:error, _} -> :error
                    success -> success
                end
        end
    end
end
