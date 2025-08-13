defmodule MyBeliaWeb.PageController do
  use MyBeliaWeb, :controller

  alias MyBelia.Accounts

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    # The login page is often custom made,
    # so skip the default app layout.
    render(conn, :login, layout: false)
  end

  def login_post(conn, %{"user" => user_params}) do
    case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Log masuk berjaya!")
        |> redirect(to: "/laman-utama-pengguna")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Emel tidak dijumpai.")
        |> render(:login, layout: false)

      {:error, :invalid_password} ->
        conn
        |> put_flash(:error, "Kata laluan tidak betul.")
        |> render(:login, layout: false)
    end
  end

  def register(conn, _params) do
    # The register page is often custom made,
    # so skip the default app layout.
    render(conn, :register, layout: false)
  end

    def register_post(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Akaun berjaya dicipta! Sila log masuk.")
        |> redirect(to: "/log-masuk")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Ralat dalam pendaftaran. Sila cuba lagi.")
        |> render(:register, layout: false)
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Log keluar berjaya!")
    |> redirect(to: "/")
  end

  def user_home(conn, _params) do
    # The user home page is often custom made,
    # so skip the default app layout.
    render(conn, :user_home, layout: false)
  end

  def admin(conn, _params) do
    # The admin page is often custom made,
    # so skip the default app layout.
    render(conn, :admin, layout: false)
  end
end
