defmodule MyBelia.Repo.Migrations.AddFileBlobToUserDocuments do
  use Ecto.Migration

  def change do
    alter table(:user_documents) do
      add :file_blob, :binary
    end
  end
end
