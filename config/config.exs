import Config

config :exodus, Exodus.Repo,
  database: "exodus",
  hostname: "localhost"

config :exodus,
  ecto_repos: [Exodus.Repo]
