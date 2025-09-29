defmodule MyBelia.Repo.Migrations.AddCreatedByIdToGrants do
  use Ecto.Migration

  def change do
    alter table(:grants) do
      add :created_by_id, references(:users, on_delete: :nilify_all)
    end

    create index(:grants, [:created_by_id])
  end
end
