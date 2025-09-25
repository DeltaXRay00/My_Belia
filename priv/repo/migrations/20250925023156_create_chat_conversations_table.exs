defmodule MyBelia.Repo.Migrations.CreateChatConversationsTable do
  use Ecto.Migration

  def change do
    create table(:chat_conversations) do
      add :contact_message_id, references(:contact_messages, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :admin_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:chat_conversations, [:contact_message_id])
    create index(:chat_conversations, [:user_id])
    create index(:chat_conversations, [:admin_id])
    create unique_index(:chat_conversations, [:contact_message_id])
  end
end
