defmodule Exodus.Invest.InvestmentFund do
  use Exodus.Schema
  alias Exodus.Invest.ShareValue

  schema "investment_funds" do
    field(:registration, :string)
    field(:name, :string)
    field(:status, :string)

    has_many(:share_values, ShareValue)
  end
end
