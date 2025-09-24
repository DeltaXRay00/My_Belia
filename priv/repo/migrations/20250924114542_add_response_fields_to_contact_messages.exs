defmodule MyBelia.Repo.Migrations.AddResponseFieldsToContactMessages do
  use Ecto.Migration

  def change do
    alter table(:contact_messages) do
      add :admin_response, :text
      add :responded_by_id, references(:users, on_delete: :nilify_all)
      add :responded_at, :utc_datetime
      add :status, :string, null: false, default: "baru"
    end

    create index(:contact_messages, [:status])
    create index(:contact_messages, [:responded_by_id])
  end
end
