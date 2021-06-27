defmodule Exodus.Stream do
  @spec chunk_lines(Enumerable.t()) :: Enumerable.t()
  def chunk_lines(stream) do
    new_line = "\r\n"

    transform_fn = fn
      :halt, leftover ->
        chunks =
          String.split(leftover, new_line)
          |> Enum.filter(fn v -> byte_size(v) > 0 end)

        {chunks, []}

      data, rest ->
        encoded_data = rest <> :unicode.characters_to_binary(data, :latin1)

        case String.split(encoded_data, new_line) do
          split_parts when length(split_parts) == 1 ->
            {[], encoded_data}

          split_parts ->
            {new_rest, chunks} = List.pop_at(split_parts, -1)
            {chunks, new_rest}
        end
    end

    stream
    |> Stream.concat([:halt])
    |> Stream.transform("", transform_fn)
  end
end
