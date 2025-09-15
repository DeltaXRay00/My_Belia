defmodule MyBelia.Repo.Migrations.EnlargeUserDocumentsFileUrl do
  use Ecto.Migration

  def up do
    alter table(:user_documents) do
      modify :file_url, :text
    end
  end

  def down do
    alter table(:user_documents) do
      modify :file_url, :string
    end
  end
end
