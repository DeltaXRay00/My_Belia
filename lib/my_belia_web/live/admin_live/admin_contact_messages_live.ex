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
  def render(assigns) do
    ~H"""
    <.admin_layout page_title={@page_title}>
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
                  <td><%= Calendar.strftime(m.inserted_at, "%d/%m/%Y %H:%M") %></td>
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
    message = ContactMessages.get_contact_message!(assigns.id)

    ~H"""
    <div class="drawer" style="position:fixed;right:0;top:0;bottom:0;width:520px;background:#fff;border-left:1px solid #e5e7eb;box-shadow:-4px 0 16px rgba(0,0,0,.06);padding:20px;overflow:auto;">
      <h2 class="section-title" style="font-size:22px;margin:0 0 12px 0;">Butiran Mesej</h2>
      <p><b>Nama:</b> <%= message.name %></p>
      <p><b>E‑mel:</b> <%= message.email %></p>
      <p><b>Tajuk:</b> <%= message.subject %></p>
      <p><b>Dihantar:</b> <%= Calendar.strftime(message.inserted_at, "%d/%m/%Y %H:%M") %></p>
      <div style="margin:12px 0 20px 0;white-space:pre-wrap;border:1px solid #e5e7eb;border-radius:8px;padding:12px;"> <%= message.message %> </div>

      <.form for={@reply_form} phx-submit="save_reply" phx-change="typing_reply">
        <input type="hidden" name="_id" value={message.id} />
        <div class="form-group">
          <label class="form-label">Balasan (opsyenal)</label>
          <textarea name="admin_response" class="form-input" rows="6"><%= message.admin_response %></textarea>
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

  @impl true
  def handle_event("save_reply", %{"_id" => id} = params, socket) do
    message = ContactMessages.get_contact_message!(id)
    attrs = %{admin_response: Map.get(params, "admin_response"), status: "dibalas", responded_by_id: socket.assigns.current_user.id, responded_at: DateTime.utc_now()}

    case ContactMessages.update_contact_message(message, attrs) do
      {:ok, _} ->
        {:noreply, push_patch(socket, to: ~p"/admin/khidmat_pengguna?status=#{socket.assigns.status}&q=#{socket.assigns.search}")}
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
