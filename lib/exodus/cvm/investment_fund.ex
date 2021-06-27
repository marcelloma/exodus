defmodule Exodus.CVM.InvestmentFund do
  defstruct [:registration, :name, :status]

  defp convert_status("EM FUNCIONAMENTO NORMAL"), do: :active
  defp convert_status("INCORPORAÇÃO"), do: :activating
  defp convert_status("FASE PRÉ-OPERACIONAL"), do: :pre_active
  defp convert_status("CANCELADA"), do: :inactive
  defp convert_status("LIQUIDAÇÃO"), do: :inactivating
  defp convert_status("EM SITUAÇÃO ESPECIAL"), do: :special
  defp convert_status("EM ANÁLISE"), do: :under_review

  @spec from_map(map) :: struct
  def from_map(%{} = map) do
    struct(__MODULE__, map)
    |> Map.update!(:status, &convert_status/1)
  end

  defp dedupe_stream_reduce(:halt, nil), do: {:halt, nil}
  defp dedupe_stream_reduce(:halt, investment_fund), do: {[investment_fund], nil}
  defp dedupe_stream_reduce(investment_fund, nil), do: {[], investment_fund}

  defp dedupe_stream_reduce(
         %{registration: registration} = investment_fund,
         %{registration: previous_registration} = previous_investment_fund
       )
       when registration != previous_registration do
    {[previous_investment_fund], investment_fund}
  end

  defp dedupe_stream_reduce(
         %{registration: registration} = investment_fund,
         %{registration: previous_registration, status: previous_status} =
           previous_investment_fund
       )
       when registration == previous_registration do
    cond do
      previous_status == :active ->
        {[], previous_investment_fund}

      true ->
        {[], investment_fund}
    end
  end

  @spec dedupe_stream(Enumerable.t()) :: Enumerable.t()
  def dedupe_stream(stream) do
    stream
    |> Enum.sort_by(&Map.get(&1, :registration))
    |> Stream.concat([:halt])
    |> Stream.transform(nil, &dedupe_stream_reduce/2)
  end
end
