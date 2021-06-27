defmodule Exodus.Invest.ShareValue do
  use Exodus.Schema
  alias Exodus.Invest.InvestmentFund

  schema "share_values" do
    field(:date, :date)
    field(:value, :decimal)

    belongs_to(:investment_fund, InvestmentFund)
  end
end
