defmodule Exodus.MixProject do
  use Mix.Project

  def project do
    [
      app: :exodus,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :iex],
      mod: {Exodus.Application, []}
    ]
  end

  defp deps do
    [
      {:castore, "~> 0.1.0"},
      {:csv, "~> 2.4"},
      {:decimal, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:mint, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:zstream, "~> 0.6.0"}
    ]
  end
end
