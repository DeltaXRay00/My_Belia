defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranLulusLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Permohonan Geran Lulus"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran_lulus(assigns)
  end
end
