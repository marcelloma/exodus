defmodule Exodus.Map do
  def rename_key(map, key, new_key) do
    value = map |> Map.get(key)

    map
    |> Map.delete(key)
    |> Map.put(new_key, value)
  end
end
