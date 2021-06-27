defmodule Exodus.CVM.ShareValue do
  defstruct [:registration, :date, :value]

  @spec from_map(map) :: struct
  def from_map(%{} = map) do
    struct(__MODULE__, map)
  end

  defp group_stream_reduce(:halt, nil), do: {:halt, nil}

  defp group_stream_reduce(:halt, [registration, share_values]),
    do: {[[registration, share_values]], nil}

  defp group_stream_reduce(%{registration: registration, date: date, value: value}, nil),
    do: {[], [registration, %{date => value}]}

  defp group_stream_reduce(
         %{registration: registration, date: date, value: value},
         [previous_registration, previous_share_values]
       )
       when registration != previous_registration do
    {[[previous_registration, previous_share_values]], [registration, %{date => value}]}
  end

  defp group_stream_reduce(
         %{registration: registration, date: date, value: value},
         [previous_registration, previous_share_values]
       )
       when registration == previous_registration do
    new_share_values =
      previous_share_values
      |> Map.put(date, value)

    {[], [registration, new_share_values]}
  end

  @spec group_stream(Enumerable.t()) :: Enumerable.t()
  def group_stream(stream) do
    stream
    |> Stream.concat([:halt])
    |> Stream.transform(nil, &group_stream_reduce/2)
  end
end
