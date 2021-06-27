defmodule Exodus.CVM.Path do
  @spec get_path(:companies | :investment_funds | :share_values, tuple()) ::
          binary()
  def get_path(:companies, _), do: "/dados/INTERMED/CAD/DADOS/cad_intermed.zip"
  def get_path(:investment_funds, _), do: "/dados/FI/CAD/DADOS/cad_fi.csv"

  def get_path(:share_values, {year, month}) do
    year = year |> Integer.to_string()

    month =
      month
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_" <> year <> month <> ".csv"
  end
end
