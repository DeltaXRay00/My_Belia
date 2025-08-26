defmodule MyBeliaWeb.AuthController do
  use MyBeliaWeb, :controller

  alias MyBelia.Accounts

  def login_post(conn, %{"user" => user_params}) do
    case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        # Update last login timestamp
        MyBelia.Accounts.update_user(user, %{last_login: DateTime.utc_now()})

        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Log masuk berjaya!")
        |> redirect(
          to:
            if(user.role == "admin" or user.role == "superadmin",
              do: "/admin",
              else: "/laman-utama-pengguna"
            )
        )

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

  def register_post(conn, %{"user" => user_params}) do
    # Set default role to "user" for new registrations
    user_params = Map.put(user_params, "role", "user")

    # Debug: Log the received parameters
    IO.inspect(user_params, label: "Registration parameters")

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        IO.inspect(user, label: "User created successfully")

        conn
        |> put_flash(:info, "Akaun berjaya dicipta! Sila log masuk.")
        |> redirect(to: "/log-masuk")

      {:error, changeset} ->
        # Debug: Log the changeset errors
        IO.inspect(changeset.errors, label: "Changeset errors")

        # Extract error messages from changeset
        error_message =
          case changeset.errors do
            [email: {"has already been taken", _}] ->
              "Emel ini sudah digunakan."

            [password: {"should be at least %{count} character(s)", [count: 6]}] ->
              "Kata laluan mesti sekurang-kurangnya 6 aksara."

            [password_confirmation: {"does not match confirmation", _}] ->
              "Kata laluan tidak sepadan."

            _ ->
              "Ralat dalam pendaftaran. Sila cuba lagi."
          end

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: "/daftar")
    end
  end

  def register_post(conn, _params) do
    # Fallback for when user parameters are missing
    conn
    |> put_flash(:error, "Data pendaftaran tidak lengkap. Sila cuba lagi.")
    |> redirect(to: "/daftar")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Log keluar berjaya!")
    |> redirect(to: "/")
  end
end
