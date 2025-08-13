defmodule MyBeliaWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    case user_id do
      nil ->
        conn
        |> put_flash(:error, "Sila log masuk untuk mengakses halaman admin.")
        |> redirect(to: "/log-masuk")
        |> halt()
      user_id ->
        user = MyBelia.Accounts.get_user!(user_id)

        case user.role do
          "admin" ->
            assign(conn, :current_user, user)
          _ ->
            conn
            |> put_flash(:error, "Anda tidak mempunyai kebenaran untuk mengakses halaman admin.")
            |> redirect(to: "/laman-utama-pengguna")
            |> halt()
        end
    end
  end
end
