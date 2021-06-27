defmodule Exodus.CVM.PostProcess do
  @spec run(Enumerable.t(), atom()) :: Enumerable.t()
  def run(stream, :companies) do
    relevant_file_name = "cad_intermed.csv"

    stream
    |> Zstream.unzip()
    |> Stream.transform("", fn
      {:entry, %Zstream.Entry{name: file_name}}, _ ->
        {[], file_name}

      {:data, :eof}, file_name ->
        {[], file_name}

      {:data, data}, ^relevant_file_name ->
        {[data], relevant_file_name}

      {:data, _}, file_name ->
        {[], file_name}
    end)
  end

  def run(stream, _kind), do: stream
end
