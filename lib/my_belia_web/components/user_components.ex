defmodule MyBeliaWeb.UserComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  # Routes generation with the ~p sigil
  use Phoenix.VerifiedRoutes,
    endpoint: MyBeliaWeb.Endpoint,
    router: MyBeliaWeb.Router,
    statics: MyBeliaWeb.static_paths()

  def user_topbar(assigns, opts \\ []) do
    brand_logo_width = Keyword.get(opts, :brand_logo_width, "170px")
    brand_logo_height = Keyword.get(opts, :brand_logo_height, "170px")
    profile_image_width = Keyword.get(opts, :profile_image_width, "auto")
    profile_image_height = Keyword.get(opts, :profile_image_height, "auto")

    # Fetch notifications if current_user present
    assigns =
      if Map.get(assigns, :current_user) do
        current_user = assigns.current_user

        {notifications, unread_count} =
          try do
            {
              MyBelia.Notifications.list_user_notifications(current_user.id),
              MyBelia.Notifications.get_unread_count(current_user.id)
            }
          rescue
            _ -> {[], 0}
          end

        Map.merge(assigns, %{
          brand_logo_width: brand_logo_width,
          brand_logo_height: brand_logo_height,
          profile_image_width: profile_image_width,
          profile_image_height: profile_image_height,
          notifications: notifications,
          unread_count: unread_count
        })
      else
        Map.merge(assigns, %{
          brand_logo_width: brand_logo_width,
          brand_logo_height: brand_logo_height,
          profile_image_width: profile_image_width,
          profile_image_height: profile_image_height,
          notifications: [],
          unread_count: 0
        })
      end

    ~H"""
    <div class="topbar">
      <div class="container topbar-inner">
        <div class="brand-left">
          <img src={~p"/images/node-4.png"} alt="KBSS" style={"width: #{@brand_logo_width}; height: #{@brand_logo_height};"} />
        </div>
        <nav class="topnav">
          <a href="/laman-utama-pengguna" class="nav-link">UTAMA</a>
          <div class="dropdown">
            <span>PERMOHONAN</span>
            <div class="dropdown-content">
              <a href="/senarai_program">Program</a>
              <a href="/senarai_kursus">Kursus</a>
              <a href="/senarai_geran">Geran</a>
            </div>
          </div>
          <a href="/dokumen_sokongan" class="nav-link">PROFIL &amp;<br>MAKLUMAT</a>
          <span>GALERI</span>
          <a href="/hubungi_kami" class="nav-link multi-line">HUBUNGI<br>KAMI</a>
        </nav>
        <div class="topnav-right" style="position: relative; display: flex; align-items: center; gap: 0;">
          <%= if @current_user && (@current_user.role == "admin" || @current_user.role == "superadmin") do %>
            <a href="/admin" class="admin-link">Admin</a>
          <% end %>
          <%= if @current_user do %>
            <% dropdown_id = "notification-dropdown" %>
            <button type="button"
                    class="notification-icon"
                    aria-label="Notifikasi"
                    aria-haspopup="menu"
                    aria-expanded="false"
                    style="background: none; border: 0; cursor: pointer; margin-right: 12px; position: relative;"
                    phx-click={JS.show(to: "##{dropdown_id}", display: "block")}>
              🔔
              <%= if @unread_count && @unread_count > 0 do %>
                <span style="position:absolute; top:-4px; right:0; background:#ef4444; color:#fff; font-size:10px; line-height:1; padding:2px 5px; border-radius:9999px;">{@unread_count}</span>
              <% end %>
            </button>

            <div id={dropdown_id}
                 role="menu"
                 aria-label="Senarai Notifikasi"
                 phx-click-away={JS.hide(to: "##{dropdown_id}")}
                 phx-window-keydown={JS.hide(to: "##{dropdown_id}")}
                 phx-key="escape"
                 style="display:none; position:absolute; right:0; top:36px; width:340px; max-height:420px; overflow:auto; background:#fff; border:1px solid #e5e7eb; box-shadow:0 12px 32px rgba(0,0,0,.15); border-radius:10px; z-index:1000;">
              <div style="position:absolute; top:-8px; right:16px; width:0; height:0; border-left:8px solid transparent; border-right:8px solid transparent; border-bottom:8px solid #e5e7eb;"></div>
              <div style="position:absolute; top:-7px; right:16px; width:0; height:0; border-left:7px solid transparent; border-right:7px solid transparent; border-bottom:7px solid #ffffff;"></div>

              <div style="padding:10px 12px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center; border-top-left-radius:10px; border-top-right-radius:10px;">
                <strong>Notifikasi</strong>
                <a href="/notifikasi" style="font-size:12px; color:#2563eb; text-decoration:none;">Lihat Semua</a>
              </div>
              <div>
                <%= if @notifications && length(@notifications) > 0 do %>
                  <%= for n <- @notifications do %>
                    <div role="menuitem"
                         tabindex="0"
                         style="padding:10px 12px; border-bottom:1px solid #f9fafb; display:flex; gap:8px; outline:none;"
                         onmouseover="this.style.background='#f9fafb'"
                         onmouseout="this.style.background='transparent'">
                      <div style="flex:1;">
                        <div style="font-weight:600; font-size:13px; color:#111827;">{n.title}</div>
                        <div style="font-size:12px; color:#374151; margin-top:2px;">{n.message}</div>
                        <div style="font-size:11px; color:#6b7280; margin-top:4px;">
                          <%= Calendar.strftime(n.inserted_at, "%d/%m/%Y %I:%M %p") %>
                        </div>
                      </div>
                      <%= if is_nil(n.read_at) do %>
                        <div style="min-width:8px; height:8px; background:#10b981; border-radius:9999px; margin-top:6px;"></div>
                      <% end %>
                    </div>
                  <% end %>
                <% else %>
                  <div style="padding:16px; font-size:13px; color:#6b7280;">Tiada notifikasi</div>
                <% end %>
              </div>
            </div>
          <% end %>
          <a href="/profil_pengguna" class="profile-icon">
            <img src={~p"/images/0b9a9b81d3a113f1a70cb1cdc85b2d2d.jpg"} alt="Profile" style={"width: #{@profile_image_width}; height: #{@profile_image_height};"} />
          </a>
          <a href="/log-keluar" class="logout-link">Log Keluar</a>
        </div>
      </div>
    </div>
    """
  end

  def user_footer(assigns, opts \\ []) do
    footer_logo_width = Keyword.get(opts, :footer_logo_width, "100px")
    footer_logo_height = Keyword.get(opts, :footer_logo_height, "100px")
    social_ellipse_width = Keyword.get(opts, :social_ellipse_width, "auto")
    social_ellipse_height = Keyword.get(opts, :social_ellipse_height, "auto")
    social_image_width = Keyword.get(opts, :social_image_width, "auto")
    social_image_height = Keyword.get(opts, :social_image_height, "auto")
    agency_logo_width = Keyword.get(opts, :agency_logo_width, "auto")
    agency_logo_height = Keyword.get(opts, :agency_logo_height, "auto")

    assigns = Map.merge(assigns, %{
      footer_logo_width: footer_logo_width,
      footer_logo_height: footer_logo_height,
      social_ellipse_width: social_ellipse_width,
      social_ellipse_height: social_ellipse_height,
      social_image_width: social_image_width,
      social_image_height: social_image_height,
      agency_logo_width: agency_logo_width,
      agency_logo_height: agency_logo_height
    })

    ~H"""
    <footer class="footer">
      <div class="container footer-inner">
        <div class="footer-top">
          <div class="footer-left">
            <img src={~p"/images/kbs-logo-100x100-1-1-15.png"} alt="KBS" class="footer-logo" style={"width: #{@footer_logo_width}; height: #{@footer_logo_height};"} />
            <div class="footer-contact">
              <div class="contact-title">KEMENTERIAN BELIA DAN SUKAN SABAH</div>
              <div class="contact-details">
                <div>Aras 10, Blok B, Wisma Muis,</div>
                <div>Karung Berkunci No.2007, 88999, Kota Kinabalu</div>
                <div>No Telefon: 088 287 556</div>
                <div>Faks: 088 240 533</div>
                <div>E-mel: kbs@sabah.gov.my</div>
              </div>
            </div>
          </div>
          <div class="footer-social">
            <div class="social-icon-container">
              <img src={~p"/images/ellipse-1-17.svg"} alt="Facebook" class="social-ellipse" style={"width: #{@social_ellipse_width}; height: #{@social_ellipse_height};"} />
              <img src={~p"/images/2175193-1-18.png"} alt="Facebook Icon" class="social-image" style={"width: #{@social_image_width}; height: #{@social_image_height};"} />
            </div>
            <div class="social-icon-container">
              <img src={~p"/images/ellipse-2-19.svg"} alt="Instagram" class="social-ellipse" style={"width: #{@social_ellipse_width}; height: #{@social_ellipse_height};"} />
              <img src={~p"/images/download-1-20.png"} alt="Instagram Icon" class="social-image" style={"width: #{@social_image_width}; height: #{@social_image_height};"} />
            </div>
          </div>
        </div>
        <div class="footer-divider"></div>
        <div class="footer-bottom">
          <div class="footer-note">Agensi di bawah Kementerian Belia dan Sukan Sabah</div>
          <div class="footer-agencies">
            <img src={~p"/images/msn-logo-2-1-22.png"} alt="Sukan Negeri Sabah" class="agency-logo" style={"width: #{@agency_logo_width}; height: #{@agency_logo_height};"} />
            <img src={~p"/images/images-1-1-24.png"} alt="Lembaga Sukan Sabah" class="agency-logo" style={"width: #{@agency_logo_width}; height: #{@agency_logo_height};"} />
            <img src={~p"/images/node-23.png"} alt="MBS Belia Sabah" class="agency-logo" style={"width: #{@agency_logo_width}; height: #{@agency_logo_height};"} />
          </div>
        </div>
      </div>
    </footer>
    """
  end

  def public_topbar(assigns, opts \\ []) do
    brand_logo_width = Keyword.get(opts, :brand_logo_width, "170px")
    brand_logo_height = Keyword.get(opts, :brand_logo_height, "170px")

    assigns = Map.merge(assigns, %{
      brand_logo_width: brand_logo_width,
      brand_logo_height: brand_logo_height
    })

    ~H"""
    <div class="topbar">
      <div class="container topbar-inner">
        <div class="brand-left">
          <img src={~p"/images/node-4.png"} alt="KBSS" style={"width: #{@brand_logo_width}; height: #{@brand_logo_height};"} />
        </div>
        <nav class="topnav">
          <a href="/" class="nav-link">UTAMA</a>
          <span class="multi-line">PROFIL &amp;<br>MAKLUMAT</span>
          <span>GALERI</span>
          <a href="/hubungi_kami" class="nav-link multi-line">HUBUNGI<br>KAMI</a>
        </nav>
        <div class="topnav-right">
          <a href="/log-masuk" class="login-link">LOG MASUK</a>
          <div class="nav-divider"></div>
          <a href="/daftar" class="login-link">DAFTAR</a>
        </div>
      </div>
    </div>
    """
  end
end
