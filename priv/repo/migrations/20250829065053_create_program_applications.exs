defmodule MyBelia.Repo.Migrations.CreateProgramApplications do
  use Ecto.Migration

  def change do
    create table(:program_applications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :program_id, references(:programs, on_delete: :delete_all), null: false
      add :user_documents_id, references(:user_documents, on_delete: :nilify_all)
      add :user_education_id, references(:user_educations, on_delete: :nilify_all)
      add :application_date, :date, null: false
      add :status, :string, default: "menunggu", null: false
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)
      add :review_date, :date
      add :review_notes, :text

      timestamps()
    end

    # Add indexes for better performance
    create index(:program_applications, [:user_id])
    create index(:program_applications, [:program_id])
    create index(:program_applications, [:status])
    create index(:program_applications, [:reviewed_by_id])

    # Ensure user can only apply once per program
    create unique_index(:program_applications, [:user_id, :program_id], name: :unique_user_program_application)
  end
end
