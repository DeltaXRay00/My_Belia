defmodule MyBelia.Repo.Migrations.AddAdminFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :daerah, :string
      add :status, :string, default: "active"
      add :last_login, :utc_datetime
    end

    # Add indexes for better performance
    create index(:users, [:role])
    create index(:users, [:status])
    create index(:users, [:daerah])
  end
end
