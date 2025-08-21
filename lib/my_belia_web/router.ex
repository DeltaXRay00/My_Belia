defmodule MyBeliaWeb.Router do
  use MyBeliaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyBeliaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug MyBeliaWeb.Plugs.Authenticate
  end

  pipeline :admin_auth do
    plug MyBeliaWeb.Plugs.AdminAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyBeliaWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/log-masuk", PageController, :login
    post "/log-masuk", PageController, :login_post
    get "/daftar", PageController, :register
    post "/daftar", PageController, :register_post
    get "/log-keluar", PageController, :logout
    get "/laman-utama", PageController, :home
    get "/home", PageController, :home

    # LiveView Routes (Public Pages)
    live "/live", PageLive.HomeLive
    live "/live/home", PageLive.HomeLive
    live "/live/laman-utama", PageLive.HomeLive
  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :auth]

    # User Dashboard and Main Pages
    get "/laman-utama-pengguna", PageController, :user_home
    get "/user-home", PageController, :user_home
    get "/dashboard", PageController, :user_home

    # User Profile
    get "/profil_pengguna", PageController, :user_profile
    get "/user-profile", PageController, :user_profile
    get "/profile", PageController, :user_profile

    # Example User Page (for demonstration)
    get "/example-user-page", PageController, :example_user_page
    get "/image-size-example", PageController, :image_size_example

    # Search functionality
    get "/search", PageController, :search
    get "/search-programs", PageController, :search_programs
    get "/search-courses", PageController, :search_courses

    # Documents and Support
    get "/dokumen_sokongan", PageController, :dokumen_sokongan
    get "/dokumen-sokongan", PageController, :dokumen_sokongan
    get "/support-documents", PageController, :dokumen_sokongan
    get "/documents", PageController, :dokumen_sokongan

    # Program List
    get "/senarai_program", PageController, :senarai_program
    get "/senarai-program", PageController, :senarai_program
    get "/program-list", PageController, :senarai_program
    get "/programs", PageController, :senarai_program

    # Program Detail
    get "/program/:id", PageController, :program_detail

    # Course Detail
    get "/course/:id", PageController, :course_detail

    # Course List
    get "/senarai_kursus", PageController, :senarai_kursus
    get "/senarai-kursus", PageController, :senarai_kursus
    get "/course-list", PageController, :senarai_kursus
    get "/courses", PageController, :senarai_kursus

    # Grant Application
    get "/permohonan_geran", PageController, :permohonan_geran
    get "/permohonan-geran", PageController, :permohonan_geran
    get "/grant-application", PageController, :permohonan_geran

    # Grant Scheme Step
    get "/skim_geran", PageController, :skim_geran
    get "/skim-geran", PageController, :skim_geran
    get "/grant-scheme", PageController, :skim_geran

                 # Support Documents Step
             get "/dokumen_sokongan_geran", PageController, :dokumen_sokongan_geran
             get "/dokumen-sokongan-geran", PageController, :dokumen_sokongan_geran

             # Application Confirmation Step
             get "/pengesahan_permohonan", PageController, :pengesahan_permohonan
             get "/pengesahan-permohonan", PageController, :pengesahan_permohonan
             get "/application-confirmation", PageController, :pengesahan_permohonan

    # LiveView Routes (User Pages) - These work alongside existing server-side routes
    live "/live/laman-utama-pengguna", UserLive.UserHomeLive
    live "/live/user-home", UserLive.UserHomeLive
    live "/live/dashboard", UserLive.UserHomeLive

    live "/live/profil_pengguna", UserLive.UserProfileLive
    live "/live/user-profile", UserLive.UserProfileLive
    live "/live/profile", UserLive.UserProfileLive

    live "/live/senarai_program", UserLive.SenaraiProgramLive
    live "/live/senarai-program", UserLive.SenaraiProgramLive
    live "/live/program-list", UserLive.SenaraiProgramLive
    live "/live/programs", UserLive.SenaraiProgramLive

    live "/live/senarai_kursus", UserLive.SenaraiKursusLive
    live "/live/senarai-kursus", UserLive.SenaraiKursusLive
    live "/live/course-list", UserLive.SenaraiKursusLive
    live "/live/courses", UserLive.SenaraiKursusLive

    live "/live/permohonan_geran", UserLive.PermohonanGeranLive
    live "/live/permohonan-geran", UserLive.PermohonanGeranLive
    live "/live/grant-application", UserLive.PermohonanGeranLive

    live "/live/skim_geran", UserLive.SkimGeranLive
    live "/live/skim-geran", UserLive.SkimGeranLive
    live "/live/grant-scheme", UserLive.SkimGeranLive

    live "/live/dokumen_sokongan_geran", UserLive.DokumenSokonganGeranLive
    live "/live/dokumen-sokongan-geran", UserLive.DokumenSokonganGeranLive

    live "/live/pengesahan_permohonan", UserLive.PengesahanPermohonanLive
    live "/live/pengesahan-permohonan", UserLive.PengesahanPermohonanLive
    live "/live/application-confirmation", UserLive.PengesahanPermohonanLive

    live "/live/dokumen_sokongan", UserLive.DokumenSokonganLive
    live "/live/dokumen-sokongan", UserLive.DokumenSokonganLive
    live "/live/support-documents", UserLive.DokumenSokonganLive
    live "/live/documents", UserLive.DokumenSokonganLive

    # LiveView Search Routes
    live "/live/search", UserLive.SearchLive
    live "/live/search-programs", UserLive.SearchProgramsLive
    live "/live/search-courses", UserLive.SearchCoursesLive
  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :admin_auth]

    # Admin Dashboard
    get "/admin", PageController, :admin
    get "/admin-dashboard", PageController, :admin
    get "/admin-panel", PageController, :admin
    get "/admin-home", PageController, :admin

    # Admin Program Management
    get "/admin/permohonan_program", PageController, :admin_permohonan_program
    post "/admin/programs", PageController, :create_program
    get "/admin/programs/:id", PageController, :get_program
    put "/admin/programs/:id", PageController, :update_program
    get "/admin/program", PageController, :admin_permohonan_program
    get "/admin/programs", PageController, :admin_permohonan_program
    get "/admin/permohonan-program", PageController, :admin_permohonan_program

    # Admin Course Management
    get "/admin/permohonan_kursus", PageController, :admin_permohonan_kursus
    post "/admin/courses", PageController, :create_course
    get "/admin/courses/:id", PageController, :get_course
    put "/admin/courses/:id", PageController, :update_course
    get "/admin/kursus", PageController, :admin_permohonan_kursus
    get "/admin/courses", PageController, :admin_permohonan_kursus
    get "/admin/permohonan-kursus", PageController, :admin_permohonan_kursus

                 # Admin Grant Management
             get "/admin/permohonan_geran", PageController, :admin_permohonan_geran
             get "/admin/permohonan-geran", PageController, :admin_permohonan_geran
             get "/admin/geran", PageController, :admin_permohonan_geran

             # Admin Grant Status Pages
             get "/admin/permohonan_geran/lulus", PageController, :admin_permohonan_geran_lulus
             get "/admin/permohonan_geran/tolak", PageController, :admin_permohonan_geran_tolak
             get "/admin/permohonan_geran/tidak_lengkap", PageController, :admin_permohonan_geran_tidak_lengkap

               # Admin Pemohon Page
  get "/pemohon", PageController, :pemohon
  get "/pemohon/lulus", PageController, :pemohon_lulus
  get "/pemohon/tolak", PageController, :pemohon_tolak
  get "/pemohon/tidak_lengkap", PageController, :pemohon_tidak_lengkap

  # Admin Kursus Pemohon Page
  get "/kursus_pemohon", PageController, :kursus_pemohon
  get "/kursus_pemohon/lulus", PageController, :kursus_pemohon_lulus
  get "/kursus_pemohon/tolak", PageController, :kursus_pemohon_tolak
  get "/kursus_pemohon/tidak_lengkap", PageController, :kursus_pemohon_tidak_lengkap

    # LiveView Routes (Admin Pages) - These work alongside existing server-side routes
    live "/live/admin", AdminLive.AdminLive
    live "/live/admin-dashboard", AdminLive.AdminLive
    live "/live/admin-panel", AdminLive.AdminLive
    live "/live/admin-home", AdminLive.AdminLive

    live "/live/admin/permohonan_program", AdminLive.AdminPermohonanProgramLive
    live "/live/admin/program", AdminLive.AdminPermohonanProgramLive
    live "/live/admin/programs", AdminLive.AdminPermohonanProgramLive
    live "/live/admin/permohonan-program", AdminLive.AdminPermohonanProgramLive

    live "/live/admin/permohonan_kursus", AdminLive.AdminPermohonanKursusLive
    live "/live/admin/kursus", AdminLive.AdminPermohonanKursusLive
    live "/live/admin/courses", AdminLive.AdminPermohonanKursusLive
    live "/live/admin/permohonan-kursus", AdminLive.AdminPermohonanKursusLive

    live "/live/admin/permohonan_geran", AdminLive.AdminPermohonanGeranLive
    live "/live/admin/permohonan-geran", AdminLive.AdminPermohonanGeranLive
    live "/live/admin/geran", AdminLive.AdminPermohonanGeranLive

    live "/live/admin/permohonan_geran/lulus", AdminLive.AdminPermohonanGeranLulusLive
    live "/live/admin/permohonan_geran/tolak", AdminLive.AdminPermohonanGeranTolakLive
    live "/live/admin/permohonan_geran/tidak_lengkap", AdminLive.AdminPermohonanGeranTidakLengkapLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyBeliaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_belia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyBeliaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
