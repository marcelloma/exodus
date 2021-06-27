defmodule Exodus.CSV do
  @separator to_string([?;])
  @double_quote to_string([?"])
  @fixed_double_quote to_string([?", ?"])

  defp fix_double_quotes(binary) do
    binary
    |> String.replace(:binary.compile_pattern(@double_quote), @fixed_double_quote)
  end

  defp enclose_with_double_quotes(binary) do
    @double_quote <> binary <> @double_quote
  end

  defp quote_csv_col(binary) do
    case String.contains?(binary, :binary.compile_pattern(@double_quote)) do
      true -> binary |> fix_double_quotes |> enclose_with_double_quotes
      false -> binary
    end
  end

  @spec map_pick_fields(map(), map()) :: map()
  def map_pick_fields(csv, fields) do
    csv
    |> Stream.map(fn {k, v} -> {Map.get(fields, k, k), v} end)
    |> Stream.filter(fn {k, _} -> is_atom(k) end)
    |> Enum.into(%{})
  end

  @spec quote_csv_row(binary) :: Enumerable.t()
  def quote_csv_row(binary) do
    binary
    |> String.split(:binary.compile_pattern(@separator))
    |> Stream.map(&quote_csv_col/1)
    |> Enum.join(@separator)
  end
end
