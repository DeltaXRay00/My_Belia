defmodule MyBelia.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :description, :text, null: false
      add :image_data, :text, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :start_time, :time, null: false
      add :end_time, :time, null: false
      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    create index(:programs, [:created_at])
  end
end
