defmodule Exodus.CVM.InvestmentFundServer do
  use GenServer

  alias Exodus.CVM

  def via_tuple(), do: {:via, Registry, {Registry.Exodus, __MODULE__}}

  @impl true
  def init(_init_args) do
    {:ok, dets} = :dets.open_file(:investment_funds_data, type: :set)

    ets = :ets.new(:investment_fund, [])

    dets
    |> :dets.to_ets(ets)
    |> :dets.close()

    {:ok, {ets, dets}}
  end

  @impl true
  def handle_call({:lookup, registration}, _from, {ets, dets}) do
    case :ets.lookup(ets, registration) do
      [{_, %CVM.InvestmentFund{} = investment_fund}] ->
        {:reply, {:ok, investment_fund}, {ets, dets}}

      [] ->
        {:reply, {:error, :not_found}, {ets, dets}}
    end
  end

  @impl true
  def handle_cast({:sync}, {ets, dets}) do
    data =
      CVM.Sync.sync(:investment_funds)
      |> Stream.map(fn %{registration: registration} = investment_fund ->
        {registration, investment_fund}
      end)
      |> Stream.into(%{})
      |> Enum.into([])

    {:ok, _} = :dets.open_file(dets, type: :set)
    ets |> :ets.insert(data)
    ets |> :ets.to_dets(dets)
    dets |> :dets.close()

    {:noreply, {ets, dets}}
  end

  def start_link(__opts) do
    GenServer.start_link(__MODULE__, :ok, name: via_tuple())
  end

  @spec sync :: :ok
  def sync() do
    via_tuple()
    |> GenServer.cast({:sync})
  end

  @spec lookup(any) :: {:ok, struct()} | {:error, atom()}
  def lookup(registration) do
    via_tuple()
    |> GenServer.call({:lookup, registration})
  end
end
