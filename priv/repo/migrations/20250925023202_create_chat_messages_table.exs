defmodule MyBelia.Repo.Migrations.CreateChatMessagesTable do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :conversation_id, references(:chat_conversations, on_delete: :delete_all), null: false
      add :sender_type, :string, null: false
      add :sender_id, references(:users, on_delete: :delete_all), null: false
      add :message, :text, null: false

      timestamps()
    end

    create index(:chat_messages, [:conversation_id])
    create index(:chat_messages, [:sender_type])
    create index(:chat_messages, [:sender_id])
    create index(:chat_messages, [:inserted_at])
  end
end
