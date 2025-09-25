defmodule MyBelia.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :message, :string
    field :type, :string
    field :title, :string
    field :read_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :user, MyBelia.Accounts.User
    belongs_to :related_message, MyBelia.ContactMessages.ContactMessage

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :title, :message, :read_at, :expires_at, :user_id, :related_message_id])
    |> validate_required([:type, :title, :message, :expires_at, :user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:related_message_id)
  end
end
