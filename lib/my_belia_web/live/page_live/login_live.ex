defmodule MyBeliaWeb.PageLive.LoginLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Log Masuk"), layout: false}
  end

  def handle_event("login", %{"user" => user_params}, socket) do
    case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Log masuk berjaya!")
         |> push_navigate(to: if(user.role == "admin", do: "/admin", else: "/laman-utama-pengguna"))}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Emel tidak dijumpai.")
         |> assign(:error, "Emel tidak dijumpai.")}

      {:error, :invalid_password} ->
        {:noreply,
         socket
         |> put_flash(:error, "Kata laluan tidak betul.")
         |> assign(:error, "Kata laluan tidak betul.")}
    end
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.login(assigns)
  end
end
