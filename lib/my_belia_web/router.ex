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

    # Public Pages (LiveView)
    live "/", PageLive.HomeLive
    live "/home", PageLive.HomeLive
    live "/laman-utama", PageLive.HomeLive
    live "/hubungi_kami", PageLive.ContactLive

    # Authentication Pages (LiveView for display, Controller for actions)
    live "/log-masuk", PageLive.LoginLive
    post "/log-masuk", AuthController, :login_post
    live "/daftar", PageLive.RegisterLive
    post "/daftar", AuthController, :register_post
    get "/log-keluar", AuthController, :logout
  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :auth]

    # User Dashboard and Main Pages (LiveView)
    live "/laman-utama-pengguna", UserLive.UserHomeLive
    live "/user-home", UserLive.UserHomeLive
    live "/dashboard", UserLive.UserHomeLive

    # Add document viewing route
    get "/documents/:id", DocumentController, :show
    get "/documents/user/:user_id/:doc_type", DocumentController, :show_by_type

    # User Profile (LiveView)
    live "/profil_pengguna", UserLive.UserProfileLive
    live "/user-profile", UserLive.UserProfileLive
    live "/profile", UserLive.UserProfileLive

    # Search functionality (LiveView)
    live "/search", UserLive.SearchLive
    live "/search-programs", UserLive.SearchProgramsLive
    live "/search-courses", UserLive.SearchCoursesLive

    # Documents and Support (LiveView)
    live "/dokumen_sokongan", UserLive.DokumenSokonganLive
    live "/dokumen-sokongan", UserLive.DokumenSokonganLive
    live "/support-documents", UserLive.DokumenSokonganLive
    live "/documents", UserLive.DokumenSokonganLive

    # Program List (LiveView)
    live "/senarai_program", UserLive.SenaraiProgramLive
    live "/senarai-program", UserLive.SenaraiProgramLive
    live "/program-list", UserLive.SenaraiProgramLive
    live "/programs", UserLive.SenaraiProgramLive

    # Program Detail (LiveView)
    live "/program/:id", UserLive.ProgramDetailLive

    # Course Detail (LiveView)
    live "/course/:id", UserLive.CourseDetailLive

    # Course List (LiveView)
    live "/senarai_kursus", UserLive.SenaraiKursusLive
    live "/senarai-kursus", UserLive.SenaraiKursusLive
    live "/course-list", UserLive.SenaraiKursusLive
    live "/courses", UserLive.SenaraiKursusLive

    # Grant Application (LiveView)
    live "/permohonan_geran", UserLive.PermohonanGeranLive
    live "/permohonan-geran", UserLive.PermohonanGeranLive
    live "/grant-application", UserLive.PermohonanGeranLive

    # Grant Scheme Step (LiveView)
    live "/skim_geran", UserLive.SkimGeranLive
    live "/skim-geran", UserLive.SkimGeranLive
    live "/grant-scheme", UserLive.SkimGeranLive

    # Support Documents Step (LiveView)
    live "/dokumen_sokongan_geran", UserLive.DokumenSokonganGeranLive
    live "/dokumen-sokongan-geran", UserLive.DokumenSokonganGeranLive
    live "/grant-support-documents", UserLive.DokumenSokonganGeranLive

    # Application Confirmation Step (LiveView)
    live "/pengesahan_permohonan", UserLive.PengesahanPermohonanLive
    live "/pengesahan-permohonan", UserLive.PengesahanPermohonanLive
    live "/application-confirmation", UserLive.PengesahanPermohonanLive

    # Application Success Page (LiveView)
    live "/permohonan_selesai", UserLive.PermohonanSelesaiLive
    live "/permohonan-selesai", UserLive.PermohonanSelesaiLive
    live "/application-success", UserLive.PermohonanSelesaiLive

    # User Applications and Log (LiveView)
    live "/permohonan", UserLive.UserApplicationsLive
    live "/log", UserLive.UserLogLive

    # Notifications (LiveView)
    live "/notifikasi", UserLive.NotificationLive

    # Contact Page (Controller)

  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :admin_auth]

    # Admin Dashboard (LiveView)
    live "/admin", AdminLive.AdminLive
    live "/admin-dashboard", AdminLive.AdminLive
    live "/admin-panel", AdminLive.AdminLive
    live "/admin-home", AdminLive.AdminLive

    # Admin Messages (LiveView)
    live "/admin/khidmat_pengguna", AdminLive.AdminContactMessagesLive

    # Admin Program Management (LiveView)
    live "/admin/permohonan_program", AdminLive.AdminPermohonanProgramLive
    live "/admin/program", AdminLive.AdminPermohonanProgramLive
    live "/admin/programs", AdminLive.AdminPermohonanProgramLive
    live "/admin/permohonan-program", AdminLive.AdminPermohonanProgramLive
    live "/admin/program/:id/pemohon", AdminLive.AdminProgramPemohonLive
    live "/admin/course/:id/pemohon", AdminLive.AdminCoursePemohonLive

    # Admin Course Management (LiveView)
    live "/admin/permohonan_kursus", AdminLive.AdminPermohonanKursusLive
    live "/admin/kursus", AdminLive.AdminPermohonanKursusLive
    live "/admin/courses", AdminLive.AdminPermohonanKursusLive
    live "/admin/permohonan-kursus", AdminLive.AdminPermohonanKursusLive

    # Admin Grant Management (LiveView)
    live "/admin/permohonan_geran", AdminLive.AdminPermohonanGeranLive
    live "/admin/permohonan-geran", AdminLive.AdminPermohonanGeranLive
    live "/admin/geran", AdminLive.AdminPermohonanGeranLive

    # Admin Reports Management (LiveView)
    live "/laporan_program", AdminLive.LaporanProgramLive
    live "/laporan_program/new", AdminLive.LaporanProgramNewLive
    live "/laporan_program/:id", AdminLive.LaporanProgramShowLive
    live "/laporan_program/:id/edit", AdminLive.LaporanProgramEditLive

    # Admin Course Logs Management (LiveView)
    live "/laporan_kursus", AdminLive.LaporanKursusLive
    live "/laporan_kursus/new", AdminLive.LaporanKursusNewLive
    live "/laporan_kursus/:id", AdminLive.LaporanKursusShowLive
    live "/laporan_kursus/:id/edit", AdminLive.LaporanKursusEditLive

    # Admin Listing Page (LiveView)
    live "/senarai_admin", AdminLive.SenaraiAdminLive
    get "/senarai_admin/new", PageController, :new_admin
    post "/senarai_admin", PageController, :create_admin
    get "/senarai_admin/:id/edit", PageController, :edit_admin
    put "/senarai_admin/:id", PageController, :update_admin

    # Admin Grant Listing (LiveView)
    live "/admin/senarai_geran", AdminLive.AdminSenaraiGeranLive

    post "/admin/skim", AdminController, :create_skim
    post "/admin/skim", AdminController, :create_skim
    # Admin Grant Status Pages (LiveView)
    live "/admin/permohonan_geran/lulus", AdminLive.AdminPermohonanGeranLulusLive
    live "/admin/permohonan_geran/tolak", AdminLive.AdminPermohonanGeranTolakLive
    live "/admin/permohonan_geran/tidak_lengkap", AdminLive.AdminPermohonanGeranTidakLengkapLive

    # Admin Pemohon Pages (LiveView)
    live "/pemohon", AdminLive.PemohonLive
    live "/pemohon/lulus", AdminLive.PemohonLulusLive
    live "/pemohon/tolak", AdminLive.PemohonTolakLive
    live "/pemohon/tidak_lengkap", AdminLive.PemohonTidakLengkapLive

    # Admin Kursus Pemohon Pages (LiveView)
    live "/kursus_pemohon", AdminLive.KursusPemohonLive
    live "/kursus_pemohon/lulus", AdminLive.KursusPemohonLulusLive
    live "/kursus_pemohon/tolak", AdminLive.KursusPemohonTolakLive
    live "/kursus_pemohon/tidak_lengkap", AdminLive.KursusPemohonTidakLengkapLive

    # Admin access to document viewing
    get "/admin/documents/:id", DocumentController, :show
    get "/admin/documents/:id/:filename", DocumentController, :show
    get "/admin/documents/user/:user_id/:doc_type", DocumentController, :show_by_type
    get "/admin/grant-docs/user/:user_id/:filename", DocumentController, :show_by_filename
    get "/admin/grant-docs/user/:user_id/type/:doc_type", DocumentController, :show_grant_by_type
  end

  # API endpoints for admin CRUD operations
  scope "/admin", MyBeliaWeb do
    pipe_through [:browser, :admin_auth]

    # Admin CRUD operations for programs
    get "/programs", PageController, :admin_programs
    get "/programs/new", PageController, :new_program
    post "/programs", PageController, :create_program
    get "/programs/:id/edit", PageController, :edit_program
    put "/programs/:id", PageController, :update_program
    delete "/programs/:id", PageController, :delete_program

    # Admin CRUD operations for courses
    get "/courses", PageController, :admin_courses
    get "/courses/new", PageController, :new_course
    post "/courses", PageController, :create_course
    get "/courses/:id/edit", PageController, :edit_course
    put "/courses/:id", PageController, :update_course
    delete "/courses/:id", PageController, :delete_course
  end

  # API endpoints for user CRUD operations
  scope "/user", MyBeliaWeb do
    pipe_through [:browser, :auth]

    # User CRUD operations for applications
    get "/applications", PageController, :user_applications
    get "/applications/new", PageController, :new_application
    post "/applications", PageController, :create_application
    get "/applications/:id/edit", PageController, :edit_application
    put "/applications/:id", PageController, :update_application
    delete "/applications/:id", PageController, :delete_application
  end

  # API endpoints for public access
  scope "/api", MyBeliaWeb do
    pipe_through :api

    # Public API endpoints
    get "/programs", PageController, :api_programs
    get "/courses", PageController, :api_courses
    get "/programs/:id", PageController, :api_program
    get "/courses/:id", PageController, :api_course
  end
end
