defmodule Exodus.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Exodus},
      Exodus.Repo,
      Exodus.CVM.InvestmentFundServer,
      Exodus.CVM.ShareValueServer
    ]

    opts = [strategy: :one_for_one, name: Exodus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
