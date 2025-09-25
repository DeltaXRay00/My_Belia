defmodule MyBelia.NotificationsTest do
  use MyBelia.DataCase

  alias MyBelia.Notifications

  describe "notifications" do
    alias MyBelia.Notifications.Notification

    import MyBelia.NotificationsFixtures

    @invalid_attrs %{message: nil, type: nil, title: nil, read_at: nil, expires_at: nil}

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Notifications.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      valid_attrs = %{message: "some message", type: "some type", title: "some title", read_at: ~U[2025-09-24 02:45:00Z], expires_at: ~U[2025-09-24 02:45:00Z]}

      assert {:ok, %Notification{} = notification} = Notifications.create_notification(valid_attrs)
      assert notification.message == "some message"
      assert notification.type == "some type"
      assert notification.title == "some title"
      assert notification.read_at == ~U[2025-09-24 02:45:00Z]
      assert notification.expires_at == ~U[2025-09-24 02:45:00Z]
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      update_attrs = %{message: "some updated message", type: "some updated type", title: "some updated title", read_at: ~U[2025-09-25 02:45:00Z], expires_at: ~U[2025-09-25 02:45:00Z]}

      assert {:ok, %Notification{} = notification} = Notifications.update_notification(notification, update_attrs)
      assert notification.message == "some updated message"
      assert notification.type == "some updated type"
      assert notification.title == "some updated title"
      assert notification.read_at == ~U[2025-09-25 02:45:00Z]
      assert notification.expires_at == ~U[2025-09-25 02:45:00Z]
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_notification(notification, @invalid_attrs)
      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end
end
