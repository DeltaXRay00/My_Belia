defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranTidakLengkapLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran_tidak_lengkap(assigns)
  end
end
