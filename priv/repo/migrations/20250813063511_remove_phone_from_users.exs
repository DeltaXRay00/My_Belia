defmodule MyBelia.Repo.Migrations.RemovePhoneFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :phone
    end
  end
end
