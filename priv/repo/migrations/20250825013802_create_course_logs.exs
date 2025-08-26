defmodule MyBelia.Repo.Migrations.CreateCourseLogs do
  use Ecto.Migration

  def change do
    create table(:course_logs) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false
      add :course_id, :integer, null: false
      add :instructor_id, :integer, null: false

      timestamps()
    end

    create index(:course_logs, [:course_id])
    create index(:course_logs, [:instructor_id])
  end
end
