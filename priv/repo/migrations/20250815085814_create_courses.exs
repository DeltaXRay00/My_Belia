defmodule MyBelia.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string, null: false
      add :description, :text, null: false
      add :image_data, :text, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :start_time, :time, null: false
      add :end_time, :time, null: false

      timestamps()
    end

    create index(:courses, [:inserted_at])
  end
end
