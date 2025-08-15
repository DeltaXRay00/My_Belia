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
