defmodule MyBelia.Repo.Migrations.CreateUserEducations do
  use Ecto.Migration

  def change do
    create table(:user_educations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :education_level, :string
      add :institution, :string
      add :field_of_study, :string
      add :course, :string
      add :graduation_date, :date

      timestamps()
    end

    create index(:user_educations, [:user_id])
  end
end
