defmodule MyBelia.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :title, :string
      add :description, :text
      add :status, :string
      add :program_id, references(:programs)
      add :course_id, references(:courses)

      timestamps(type: :utc_datetime)
    end

    create index(:reports, [:program_id])
    create index(:reports, [:course_id])
  end
end
