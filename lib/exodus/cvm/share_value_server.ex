defmodule Exodus.CVM.ShareValueServer do
  use GenServer

  alias Exodus.CVM

  def via_tuple(), do: {:via, Registry, {Registry.Exodus, __MODULE__}}

  @impl true
  def init(_init_args) do
    {:ok, dets} = :dets.open_file(:share_value_data, type: :bag)
    {:ok, dets_sync} = :dets.open_file(:share_value_sync, type: :set)

    ets = :ets.new(:share_value, [:bag])

    dets
    |> :dets.to_ets(ets)
    |> :dets.close()

    dets_sync
    |> :dets.close()

    {:ok, {ets, dets, dets_sync}}
  end

  @impl true
  def handle_call({:lookup, registration}, _from, {ets, dets, dets_sync}) do
    IO.inspect(:ets.lookup(ets, registration))

    case :ets.lookup(ets, registration) do
      [{_, %{} = share_values}] ->
        {:reply, {:ok, share_values}, {ets, dets, dets_sync}}

      [] ->
        {:reply, {:error, :not_found}, {ets, dets, dets_sync}}
    end
  end

  @impl true
  def handle_cast({:sync, {year, month}}, {ets, dets, dets_sync}) do
    {:ok, _} = :dets.open_file(dets_sync, type: :set)
    true = :dets.insert_new(dets_sync, {{year, month}})
    dets_sync |> :dets.close()

    IO.puts("START")

    data = CVM.Sync.sync(:share_values, {year, month}) |> Enum.into([])

    {:ok, _} = :dets.open_file(dets, type: :bag)
    ets |> :ets.insert(data)
    ets |> :ets.to_dets(dets)
    dets |> :dets.close()

    IO.puts("DONE")

    {:noreply, {ets, dets, dets_sync}}
  end

  def start_link(__opts) do
    GenServer.start_link(__MODULE__, :ok, name: via_tuple())
  end

  @spec sync({integer(), integer()}) :: :ok
  def sync({year, month}) do
    via_tuple() |> GenServer.cast({:sync, {year, month}})
  end

  @spec lookup(any) :: {:ok, map()} | {:error, atom()}
  def lookup(registration) do
    via_tuple() |> GenServer.call({:lookup, registration})
  end
end
