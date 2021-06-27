defmodule Exodus.CVM.ParseCSV do
  @investment_fund_map %{
    "CNPJ_FUNDO" => :registration,
    "DENOM_SOCIAL" => :name,
    "SIT" => :status
  }
  defp parse_row(row, :investment_funds), do: parse_row(row, @investment_fund_map)

  @share_value_map %{
    "CNPJ_FUNDO" => :registration,
    "DT_COMPTC" => :date,
    "VL_QUOTA" => :value
  }
  defp parse_row(row, :share_values), do: parse_row(row, @share_value_map)

  defp parse_row(csv_row, field_map) do
    csv_row
    |> Exodus.CSV.map_pick_fields(field_map)
  end

  @spec parse_csv(Enumerable.t(), atom()) :: Enumerable.t()
  def parse_csv(stream, kind) do
    stream
    |> Stream.map(&parse_row(&1, kind))
  end
end
