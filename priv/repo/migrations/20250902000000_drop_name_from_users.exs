defmodule MyBelia.Repo.Migrations.DropNameFromUsers do
  use Ecto.Migration

  def up do
    # Drop column if exists (supports Postgres)
    execute "ALTER TABLE users DROP COLUMN IF EXISTS name;"
  end

  def down do
    # Recreate column on rollback
    alter table(:users) do
      add :name, :string
    end
  end
end
