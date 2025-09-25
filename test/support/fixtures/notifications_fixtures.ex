defmodule MyBelia.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyBelia.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        expires_at: ~U[2025-09-24 02:45:00Z],
        message: "some message",
        read_at: ~U[2025-09-24 02:45:00Z],
        title: "some title",
        type: "some type"
      })
      |> MyBelia.Notifications.create_notification()

    notification
  end
end
