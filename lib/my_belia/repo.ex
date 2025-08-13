defmodule MyBelia.Repo do
  use Ecto.Repo,
    otp_app: :my_belia,
    adapter: Ecto.Adapters.Postgres
end
