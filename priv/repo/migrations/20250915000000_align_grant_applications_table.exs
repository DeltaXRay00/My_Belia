defmodule MyBelia.Repo.Migrations.AlignGrantApplicationsTable do
  use Ecto.Migration

  def up do
    # Create table if it does not exist (minimal columns)
    create_if_not_exists table(:grant_applications) do
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    # Ensure required columns exist using IF NOT EXISTS to avoid duplicates
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS grant_scheme varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS grant_amount numeric"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_duration varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_name varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_objective text"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS target_group text"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_location varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_start_date date"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS project_end_date date"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS equipment_cost numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS material_cost numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS transport_cost numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS admin_cost numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS other_cost numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS total_budget numeric DEFAULT 0"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS supporting_documents text[] DEFAULT '{}'"

    create_if_not_exists index(:grant_applications, [:user_id])
  end

  def down do
    :ok
  end
end
