defmodule Exodus.Repo.Migrations.CreateShareValues do
  use Ecto.Migration

  def change do
    create table("share_values", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :investment_fund_id, references("investment_funds", type: :uuid)
      add :date, :date
      add :value, :decimal
    end

    create index("share_values", [:investment_fund_id, :date], unique: true)
  end
end
