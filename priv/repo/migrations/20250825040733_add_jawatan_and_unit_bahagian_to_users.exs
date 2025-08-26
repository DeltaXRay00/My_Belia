defmodule MyBelia.Repo.Migrations.AddJawatanAndUnitBahagianToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :jawatan, :string
      add :unit_bahagian, :string
    end
  end
end
