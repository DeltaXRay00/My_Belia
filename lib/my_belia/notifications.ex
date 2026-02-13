defmodule MyBelia.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo

  alias MyBelia.Notifications.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  @doc """
  Gets notifications for a specific user.
  """
  def list_user_notifications(user_id) do
    Notification
    |> where([n], n.user_id == ^user_id)
    |> where([n], n.expires_at > ^DateTime.utc_now())
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets unread notification count for a user.
  """
  def get_unread_count(user_id) do
    Notification
    |> where([n], n.user_id == ^user_id)
    |> where([n], is_nil(n.read_at))
    |> where([n], n.expires_at > ^DateTime.utc_now())
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Marks a notification as read.
  """
  def mark_as_read(notification) do
    update_notification(notification, %{read_at: DateTime.utc_now()})
  end

  @doc """
  Creates a notification for admin response.
  """
  def create_admin_response_notification(user_id, contact_message) do
    expires_at = DateTime.add(DateTime.utc_now(), 7, :day)

    create_notification(%{
      user_id: user_id,
      type: "admin_reply",
      title: "Admin telah membalas mesej anda",
      message: "Admin telah membalas mesej anda dengan tajuk: #{contact_message.subject}",
      related_message_id: contact_message.id,
      expires_at: expires_at
    })
  end

  @doc """
  Deletes expired notifications (30+ days old).
  """
  def cleanup_expired_notifications do
    Notification
    |> where([n], n.expires_at <= ^DateTime.utc_now())
    |> Repo.delete_all()
  end
end
