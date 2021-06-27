defmodule Exodus.Repo.Migrations.CreateInvestmentFunds do
  use Ecto.Migration

  def change do
    create table("investment_funds", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :registration, :string
      add :name, :string
      add :status, :string
    end

    create index("investment_funds", [:registration], unique: true)
  end
end
