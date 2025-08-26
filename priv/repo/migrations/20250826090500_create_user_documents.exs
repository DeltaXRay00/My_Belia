defmodule MyBelia.Repo.Migrations.CreateUserDocuments do
  use Ecto.Migration

  def change do
    # Ensure table exists first
    create_if_not_exists table(:user_documents) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :doc_type, :string, null: false
      add :file_name, :string, null: false
      add :content_type, :string
      add :file_size, :integer
      add :file_url, :string

      timestamps()
    end

    # If the table already existed without the columns (from an interrupted run), add them now
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS user_id integer REFERENCES users(id) ON DELETE CASCADE;"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS doc_type varchar(100);"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS file_name varchar(255);"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS content_type varchar(100);"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS file_size integer;"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS file_url varchar(500);"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS inserted_at timestamp without time zone;"
    execute "ALTER TABLE user_documents ADD COLUMN IF NOT EXISTS updated_at timestamp without time zone;"

    create_if_not_exists index(:user_documents, [:user_id])
    create_if_not_exists index(:user_documents, [:doc_type])
    create_if_not_exists unique_index(:user_documents, [:user_id, :doc_type], name: :unique_user_doc_type)
  end
end
