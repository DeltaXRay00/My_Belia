defmodule MyBelia.Repo.Migrations.CreateUserDocumentsTableNew do
  use Ecto.Migration

  def change do
    create table(:user_documents) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :doc_type, :string, null: false
      add :file_name, :string, null: false
      add :content_type, :string
      add :file_size, :integer
      add :file_url, :string

      timestamps()
    end

    create index(:user_documents, [:user_id])
    create index(:user_documents, [:doc_type])
    create unique_index(:user_documents, [:user_id, :doc_type], name: :unique_user_doc_type)
  end
end
