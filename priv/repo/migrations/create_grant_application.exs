defmodule MyBelia.Repo.Migrations.CreateGrantApplications do
  use Ecto.Migration

  def change do
    create table(:grant_applications) do
      add :user_id, references(:users, on_delete: :nothing)
      add :grant_scheme, :string
      add :grant_amount, :decimal, precision: 12, scale: 2
      add :project_duration, :string
      add :project_name, :string
      add :project_objective, :text
      add :target_group, :string
      add :project_location, :string
      add :project_start_date, :date
      add :project_end_date, :date
      add :equipment_cost, :decimal, precision: 12, scale: 2, default: 0
      add :material_cost, :decimal, precision: 12, scale: 2, default: 0
      add :transport_cost, :decimal, precision: 12, scale: 2, default: 0
      add :admin_cost, :decimal, precision: 12, scale: 2, default: 0
      add :other_cost, :decimal, precision: 12, scale: 2, default: 0
      add :total_budget, :decimal, precision: 12, scale: 2, default: 0
      add :supporting_documents, {:array, :string}, default: []

      timestamps()
    end

    create index(:grant_applications, [:user_id])
  end
end
