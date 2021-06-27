defmodule Exodus.CVM do
  @spec download(:companies | :investment_funds | :share_values, tuple) :: Enumerable.t()
  def download(kind, opts \\ {}) do
    Exodus.CVM.Path.get_path(kind, opts)
    |> Exodus.CVM.HTTP.request()
    |> Exodus.CVM.PostProcess.run(kind)
    |> Exodus.Stream.chunk_lines()
    |> Stream.map(&Exodus.CSV.quote_csv_row/1)
    |> CSV.decode!(separator: ?;, headers: true)
    |> Exodus.CVM.ParseCSV.parse_csv(kind)
  end
end
