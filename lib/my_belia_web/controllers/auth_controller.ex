defmodule MyBeliaWeb.AuthController do
  use MyBeliaWeb, :controller

  alias MyBelia.Accounts

  def login_post(conn, %{"user" => user_params}) do
    case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Log masuk berjaya!")
        |> redirect(to: if(user.role == "admin", do: "/admin", else: "/laman-utama-pengguna"))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Emel tidak dijumpai.")
        |> redirect(to: "/log-masuk")

      {:error, :invalid_password} ->
        conn
        |> put_flash(:error, "Kata laluan tidak betul.")
        |> redirect(to: "/log-masuk")
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Log keluar berjaya!")
    |> redirect(to: "/")
  end
end
