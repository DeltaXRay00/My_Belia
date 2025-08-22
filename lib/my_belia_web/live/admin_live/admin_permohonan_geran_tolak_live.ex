defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranTolakLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Permohonan Geran Tolak"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran_tolak(assigns)
  end
end
