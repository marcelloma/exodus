defmodule Exodus.CVM.HTTP do
  defp stream_http_response(%{last_response_status: :done, conn: conn}) do
    Mint.HTTP.close(conn)

    nil
  end

  defp stream_http_response(%{request_ref: request_ref, conn: conn} = state) do
    receive do
      message ->
        {:ok, conn, responses} = Mint.HTTP.stream(conn, message)

        last_response_status =
          responses
          |> List.last()
          |> elem(0)

        new_state =
          state
          |> Map.put(:conn, conn)
          |> Map.put(:last_response_status, last_response_status)

        chunk =
          responses
          |> Stream.filter(fn
            {:data, ^request_ref, _} -> true
            _response -> false
          end)
          |> Stream.map(&elem(&1, 2))
          |> Enum.reduce(<<>>, &Kernel.<>/2)

        case chunk do
          <<>> -> {new_state, new_state}
          _ -> {new_state |> Map.put(:chunk, chunk), new_state}
        end
    end
  end

  defp get_connection do
    {:ok, conn} = Mint.HTTP.connect(:http, "dados.cvm.gov.br", 80)

    conn
  end

  @spec request(binary) :: Enumerable.t()
  def request(path) do
    {:ok, conn, request_ref} = get_connection() |> Mint.HTTP.request("GET", path, [], "")

    %{conn: conn, request_ref: request_ref}
    |> Stream.unfold(&stream_http_response/1)
    |> Stream.map(&Map.get(&1, :chunk))
    |> Stream.reject(&Kernel.is_nil/1)
  end
end
