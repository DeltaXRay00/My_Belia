defmodule MyBelia.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :full_name, :string, null: false
      add :phone, :string
      add :role, :string, default: "user", null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
