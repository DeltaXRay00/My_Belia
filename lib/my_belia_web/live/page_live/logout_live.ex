defmodule MyBeliaWeb.PageLive.LogoutLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> put_flash(:info, "Log keluar berjaya!")
     |> push_navigate(to: "/")}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.home(assigns)
  end
end
