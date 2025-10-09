defmodule MyBeliaWeb.AdminLive.AdminContactMessagesLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.ContactMessages

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Khidmat Pengguna")
     |> assign(:search, "")
     |> assign(:status, "semua")
     |> assign(:messages, ContactMessages.list_contact_messages())
     |> assign(:params, %{})
     |> assign(:reply_form, to_form(%{}, as: :reply)),
     layout: false}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/khidmat_pengguna?status=#{socket.assigns.status}&q=#{q}")}
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/khidmat_pengguna?status=#{status}&q=#{socket.assigns.search}")}
  end

  @impl true
  def handle_event("save_reply", %{"_id" => id} = params, socket) do
    message = ContactMessages.get_contact_message!(id)
    attrs = %{admin_response: Map.get(params, "admin_response"), status: "dibalas", responded_by_id: socket.assigns.current_user.id, responded_at: DateTime.utc_now()}

    case ContactMessages.update_contact_message(message, attrs) do
      {:ok, updated_message} ->
        # Send email notification to user
        send_admin_response_email(updated_message)

        # Create bell notification for logged-in users
        create_bell_notification_if_user_exists(updated_message)

        {:noreply, push_patch(socket, to: ~p"/admin/khidmat_pengguna?status=#{socket.assigns.status}&q=#{socket.assigns.search}")}
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.admin_layout page_title={@page_title} current_page="khidmat">
      <div class="contact-admin-controls" style="display:flex; gap:12px; align-items:center; margin:12px 30px 20px 30px;">
        <form phx-change="search" style="flex:1;">
          <input type="text" name="q" value={@search} placeholder="Cari nama, e‑mel atau tajuk" class="search-input" />
        </form>
        <select phx-change="filter" name="status" class="filter-select">
          <option value="semua" selected={@status == "semua"}>Semua</option>
          <option value="baru" selected={@status == "baru"}>Baru</option>
          <option value="dibaca" selected={@status == "dibaca"}>Dibaca</option>
          <option value="dibalas" selected={@status == "dibalas"}>Dibalas</option>
        </select>
      </div>

      <div class="applications-table" style="padding:0 30px 30px 30px;">
        <table class="data-table">
          <thead>
            <tr>
              <th style="text-align:left">Nama</th>
              <th style="text-align:left">E‑mel</th>
              <th style="text-align:left">Tajuk</th>
              <th>Tarikh</th>
              <th>Status</th>
              <th>Tindakan</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@messages) do %>
              <tr>
                <td colspan="6" class="empty-row">
                  <div class="empty-message">Tiada mesej setakat ini.</div>
                </td>
              </tr>
            <% else %>
              <%= for m <- @messages do %>
                <tr phx-click={JS.patch(~p"/admin/khidmat_pengguna?status=#{@status}&q=#{@search}&id=#{m.id}")}
                    style="cursor:pointer">
                  <td style="text-align:left"><%= m.name %></td>
                  <td style="text-align:left"><%= m.email %></td>
                  <td style="text-align:left"><%= m.subject %></td>
                  <td><%= convert_to_malaysia_time(m.inserted_at) %></td>
                  <td>
                    <%= case m.status || "baru" do %>
                      <% "baru" -> %><span class="status-badge status-badge--menunggu">baru</span>
                      <% "dibaca" -> %><span class="status-badge status-badge--tidak_lengkap">dibaca</span>
                      <% "dibalas" -> %><span class="status-badge status-badge--diluluskan">dibalas</span>
                    <% end %>
                  </td>
                  <td>
                    <div class="action-icons centered">
                      <button class="action-icon view-btn" aria-label="Lihat">👁️</button>
                    </div>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <%= if assigns[:params] && assigns.params["id"] do %>
        <.message_detail id={String.to_integer(assigns.params["id"])} status={@status} search={@search} reply_form={@reply_form} />
      <% end %>
    </.admin_layout>
    """
  end

  attr :id, :integer, required: true
  attr :status, :string, required: true
  attr :search, :string, required: true
  attr :reply_form, :any, required: true
  def message_detail(assigns) do
    assigns = assign(assigns, :message, ContactMessages.get_contact_message!(assigns.id))

    ~H"""
    <div class="drawer" style="position:fixed;right:0;top:0;bottom:0;width:520px;background:#fff;border-left:1px solid #e5e7eb;box-shadow:-4px 0 16px rgba(0,0,0,.06);padding:20px;overflow:auto;">
      <h2 class="section-title" style="font-size:22px;margin:0 0 12px 0;">Butiran Mesej</h2>
      <p><b>Nama:</b> <%= @message.name %></p>
      <p><b>E‑mel:</b> <%= @message.email %></p>
      <p><b>Tajuk:</b> <%= @message.subject %></p>
      <p><b>Dihantar:</b> <%= convert_to_malaysia_time(@message.inserted_at) %></p>
      <div style="margin:12px 0 20px 0;white-space:pre-wrap;border:1px solid #e5e7eb;border-radius:8px;padding:12px;"> <%= @message.message %> </div>

      <.form for={@reply_form} phx-submit="save_reply" phx-change="typing_reply">
        <input type="hidden" name="_id" value={@message.id} />
        <div class="form-group">
          <label class="form-label">Balasan (opsyenal)</label>
          <textarea name="admin_response" class="form-input" rows="6"><%= @message.admin_response %></textarea>
        </div>
        <div style="display:flex;gap:8px;">
          <button type="submit" class="submit-btn">Hantar Balasan</button>
          <button type="button" phx-click={JS.patch(~p"/admin/khidmat_pengguna?status=#{@status}&q=#{@search}")} class="form-input" style="padding:0.5rem 1rem;">Tutup</button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    # keep assigns updated and allow detail drawer via id
    status = Map.get(params, "status", socket.assigns.status)
    search = Map.get(params, "q", socket.assigns.search)
    messages = ContactMessages.list_contact_messages(status: status, search: search)

    {:noreply, assign(socket, params: params, status: status, search: search, messages: messages)}
  end

  defp send_admin_response_email(contact_message) do
    # Create email content
    email_content = create_admin_response_email(contact_message)

    # Send email using MyBelia.Mailer with logging
    case MyBelia.Mailer.deliver(email_content) do
      {:ok, response} ->
        require Logger
        Logger.info("Email sent OK: #{inspect(response)}")
        :ok
      {:error, reason} ->
        require Logger
        Logger.error("Email send failed: #{inspect(reason)}")
        :error
    end
  end

  defp create_admin_response_email(contact_message) do
    %Swoosh.Email{
      to: [{contact_message.name, contact_message.email}],
      from: {"MyBelia System", "mark.kevinfred@gmail.com"},
      subject: "[MyBelia] Balasan untuk mesej anda",
      html_body: create_email_html_body(contact_message),
      text_body: create_email_text_body(contact_message)
    }
  end

  defp create_email_html_body(contact_message) do
    malaysia_time_original = convert_to_malaysia_time(contact_message.inserted_at)
    malaysia_time_response = convert_to_malaysia_time(contact_message.responded_at)

    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Balasan dari MyBelia</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .content { background-color: #ffffff; padding: 20px; border: 1px solid #e9ecef; border-radius: 8px; }
        .original-message { background-color: #f8f9fa; padding: 15px; border-left: 4px solid #007bff; margin: 15px 0; }
        .admin-response { background-color: #e8f5e8; padding: 15px; border-left: 4px solid #28a745; margin: 15px 0; }
        .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e9ecef; font-size: 12px; color: #6c757d; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h2>Terima kasih atas mesej anda</h2>
          <p>Berikut adalah balasan dari admin MyBelia:</p>
        </div>

        <div class="content">
          <div class="original-message">
            <h3>Mesej Asal Anda:</h3>
            <p><strong>Tajuk:</strong> #{contact_message.subject}</p>
            <p><strong>Tarikh:</strong> #{malaysia_time_original}</p>
            <p><strong>Mesej:</strong></p>
            <p>#{String.replace(contact_message.message, "\n", "<br>")}</p>
          </div>

          <div class="admin-response">
            <h3>Balasan Admin:</h3>
            <p><strong>Tarikh:</strong> #{malaysia_time_response}</p>
            <p><strong>Mesej:</strong></p>
            <p>#{String.replace(contact_message.admin_response, "\n", "<br>")}</p>
          </div>
        </div>

        <div class="footer">
          <p>Sekian, terima kasih.</p>
          <p>MyBelia Team</p>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp create_email_text_body(contact_message) do
    malaysia_time_original = convert_to_malaysia_time(contact_message.inserted_at)
    malaysia_time_response = convert_to_malaysia_time(contact_message.responded_at)

    """
    Terima kasih atas mesej anda. Berikut adalah balasan dari admin MyBelia:

    --- MESEJ ASAL ---
    Tajuk: #{contact_message.subject}
    Tarikh: #{malaysia_time_original}
    Mesej: #{contact_message.message}

    --- BALASAN ADMIN ---
    Tarikh: #{malaysia_time_response}
    Mesej: #{contact_message.admin_response}

    Sekian, terima kasih.
    MyBelia Team
    """
  end

  defp convert_to_malaysia_time(datetime) do
    # Convert UTC datetime to Malaysia time (UTC+8)
    malaysia_datetime = case datetime do
      %DateTime{} = dt -> DateTime.add(dt, 8 * 60 * 60, :second)
      %NaiveDateTime{} = ndt ->
        dt = DateTime.from_naive!(ndt, "Etc/UTC")
        DateTime.add(dt, 8 * 60 * 60, :second)
    end
    Calendar.strftime(DateTime.to_naive(malaysia_datetime), "%d/%m/%Y %I:%M %p")
  end

  defp create_bell_notification_if_user_exists(_contact_message) do
    # Check if the user who sent the message is logged in
    # This would require linking contact messages to users
    # For now, we'll implement this when we have user identification
    # TODO: Implement user identification for contact messages
  end
end
