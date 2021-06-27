defmodule Exodus.Repo do
  use Ecto.Repo,
    otp_app: :exodus,
    adapter: Ecto.Adapters.Postgres
end
