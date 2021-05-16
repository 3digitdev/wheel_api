defmodule WheelApi.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def up do
    create table("wheels") do
        add :ticker,            :string
        add :description,       :string
        add :subtotal,          :float,     default: 0.0
        add :positions_closed,  :boolean,   default: true
        add :assigned_shares,   :boolean,   default: false
    end

    create table("shares") do
        add :quantity,          :integer,   default: 0
        add :cost,              :float,     default: 0.0
        add :sale_date,         :date
        add :action,            :string
        add :wheel_id,          references("wheels", on_delete: :delete_all)
    end

    create table("options") do
        add :type,              :string
        add :action,            :string,    default: "SELL"
        add :strike,            :float
        add :quantity,          :integer,   default: 1
        add :premium,           :float
        add :open,              :boolean,   default: true
        add :sale_date,         :date
        add :exp_date,          :date
        add :wheel_id,          references("wheels", on_delete: :delete_all)
    end
  end

  def down do
    drop table("options")
    drop table("shares")
    drop table("wheels")
  end
end
