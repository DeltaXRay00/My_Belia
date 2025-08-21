defmodule MyBeliaWeb.PageLive.RegisterLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Daftar"), layout: false}
  end

  def handle_event("register", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Akaun berjaya dicipta! Sila log masuk.")
         |> push_navigate(to: "/log-masuk")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat dalam pendaftaran. Sila cuba lagi.")
         |> assign(:error, "Ralat dalam pendaftaran. Sila cuba lagi.")}
    end
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.register(assigns)
  end
end
