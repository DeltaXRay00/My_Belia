defmodule MyBeliaWeb.UserLive.NotificationLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Notifications

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    if current_user do
      notifications = Notifications.list_user_notifications(current_user.id)
      unread_count = Notifications.get_unread_count(current_user.id)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:notifications, notifications)
       |> assign(:unread_count, unread_count)
       |> assign(:show_dropdown, false)}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("toggle_notifications", _params, socket) do
    {:noreply, assign(socket, :show_dropdown, !socket.assigns.show_dropdown)}
  end

  @impl true
  def handle_event("mark_notification_read", %{"id" => id}, socket) do
    notification = Notifications.get_notification!(id)
    Notifications.mark_as_read(notification)

    # Refresh notifications and unread count
    notifications = Notifications.list_user_notifications(socket.assigns.current_user.id)
    unread_count = Notifications.get_unread_count(socket.assigns.current_user.id)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, unread_count)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="notification-bell" phx-click="toggle_notifications">
      <span class="bell-icon">🔔</span>
      <%= if @unread_count && @unread_count > 0 do %>
        <span class="notification-badge"><%= @unread_count %></span>
      <% end %>
    </div>

    <%= if @show_dropdown do %>
      <div class="notification-dropdown" id="notification-dropdown">
        <div class="notification-header">
          <h3>Notifikasi</h3>
          <a href="/notifikasi" class="view-all-link">Lihat Semua</a>
        </div>
        <div class="notification-list">
          <%= if @notifications && length(@notifications) > 0 do %>
            <%= for notification <- @notifications do %>
              <div class="notification-item" phx-click="mark_notification_read" phx-value-id={notification.id}>
                <div class="notification-content">
                  <div class="notification-title"><%= notification.title %></div>
                  <div class="notification-message"><%= notification.message %></div>
                  <div class="notification-time"><%= Calendar.strftime(notification.inserted_at, "%d/%m/%Y %I:%M %p") %></div>
                </div>
                <%= if is_nil(notification.read_at) do %>
                  <div class="unread-indicator"></div>
                <% end %>
              </div>
            <% end %>
          <% else %>
            <div class="no-notifications">Tiada notifikasi</div>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end
end
