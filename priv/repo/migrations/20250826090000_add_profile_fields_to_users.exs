defmodule MyBelia.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    # Use idempotent raw SQL to avoid duplicate column errors if partially applied previously
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS ic_number varchar(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date date;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_place varchar(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS gender varchar(50);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number varchar(50);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS religion varchar(100);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS race varchar(100);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS residential_address text;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS mailing_address text;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS education_level varchar(100);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS institution varchar(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS field_of_study varchar(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS course varchar(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS graduation_date date;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url varchar(500);"

    create_if_not_exists index(:users, [:ic_number])
    create_if_not_exists index(:users, [:gender])
    create_if_not_exists index(:users, [:race])
    create_if_not_exists index(:users, [:education_level])
  end
end
