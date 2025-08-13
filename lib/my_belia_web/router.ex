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
  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :auth]

    get "/laman-utama-pengguna", PageController, :user_home
  end

  scope "/", MyBeliaWeb do
    pipe_through [:browser, :admin_auth]

    get "/admin", PageController, :admin
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
