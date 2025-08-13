defmodule MyBeliaWeb.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    case user_id do
      nil ->
        conn
        |> put_flash(:error, "Sila log masuk untuk mengakses halaman ini.")
        |> redirect(to: "/log-masuk")
        |> halt()
      user_id ->
        user = MyBelia.Accounts.get_user!(user_id)
        assign(conn, :current_user, user)
    end
  end
end
