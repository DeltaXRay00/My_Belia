defmodule MyBelia.Repo.Migrations.CreateNotificationsTable do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :title, :string, null: false
      add :message, :text, null: false
      add :related_message_id, references(:contact_messages, on_delete: :delete_all)
      add :read_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:type])
    create index(:notifications, [:read_at])
    create index(:notifications, [:expires_at])
    create index(:notifications, [:related_message_id])
  end
end
