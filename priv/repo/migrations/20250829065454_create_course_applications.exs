defmodule MyBelia.Repo.Migrations.CreateCourseApplications do
  use Ecto.Migration

  def change do
    create table(:course_applications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false
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
    create index(:course_applications, [:user_id])
    create index(:course_applications, [:course_id])
    create index(:course_applications, [:status])
    create index(:course_applications, [:reviewed_by_id])

    # Ensure user can only apply once per course
    create unique_index(:course_applications, [:user_id, :course_id], name: :unique_user_course_application)
  end
end
