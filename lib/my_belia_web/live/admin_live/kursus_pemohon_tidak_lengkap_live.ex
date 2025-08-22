defmodule MyBeliaWeb.AdminLive.KursusPemohonTidakLengkapLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Kursus Pemohon Tidak Lengkap"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.kursus_pemohon_tidak_lengkap(assigns)
  end
end
