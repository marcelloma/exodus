defmodule Exodus.CVM.Sync do
  alias Exodus.CVM
  alias Exodus.CVM.{InvestmentFund, ShareValue}

  @spec sync(:investment_funds) :: Enumerable.t()
  def sync(:investment_funds) do
    CVM.download(:investment_funds)
    |> Stream.map(&InvestmentFund.from_map/1)
    |> InvestmentFund.dedupe_stream()
  end

  @spec sync(:share_values, {integer, integer}) :: Enumerable.t()
  def sync(:share_values, {year, month}) do
    CVM.download(:share_values, {year, month})
    |> Stream.map(&ShareValue.from_map/1)
    |> Stream.map(fn %{registration: registration, date: date, value: value} ->
      {registration, {date, value}}
    end)

    # |> ShareValue.group_stream()
  end
end
