defmodule MyBeliaWeb.UserComponents do
  use Phoenix.Component

  # Routes generation with the ~p sigil
  use Phoenix.VerifiedRoutes,
    endpoint: MyBeliaWeb.Endpoint,
    router: MyBeliaWeb.Router,
    statics: MyBeliaWeb.static_paths()

  def user_topbar(assigns, opts \\ []) do
    brand_logo_width = Keyword.get(opts, :brand_logo_width, "auto")
    brand_logo_height = Keyword.get(opts, :brand_logo_height, "auto")
    profile_image_width = Keyword.get(opts, :profile_image_width, "auto")
    profile_image_height = Keyword.get(opts, :profile_image_height, "auto")

    assigns = Map.merge(assigns, %{
      brand_logo_width: brand_logo_width,
      brand_logo_height: brand_logo_height,
      profile_image_width: profile_image_width,
      profile_image_height: profile_image_height
    })

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
              <a href="/permohonan_geran">Geran</a>
            </div>
          </div>
          <a href="/dokumen_sokongan" class="nav-link">PROFIL &amp;<br>MAKLUMAT</a>
          <span>GALERI</span>
          <span class="multi-line">HUBUNGI<br>KAMI</span>
        </nav>
        <div class="topnav-right">
          <%= if @current_user && @current_user.role == "admin" do %>
            <a href="/admin" class="admin-link">Admin</a>
          <% end %>
          <a href="/profil_pengguna" class="profile-icon">
            <img src={~p"/images/0b9a9b81d3a113f1a70cb1cdc85b2d2d.jpg"} alt="Profile" style={"width: #{@profile_image_width}; height: #{@profile_image_height};"} />
          </a>
          <%= unless @current_user && @current_user.role == "admin" do %>
            <a href="/log-keluar" class="logout-link">Log Keluar</a>
          <% end %>
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
    brand_logo_width = Keyword.get(opts, :brand_logo_width, "auto")
    brand_logo_height = Keyword.get(opts, :brand_logo_height, "auto")

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
          <span class="multi-line">HUBUNGI<br>KAMI</span>
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
