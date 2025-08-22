defmodule MyBeliaWeb.AdminLive.KursusPemohonLulusLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Kursus Pemohon Lulus"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.kursus_pemohon_lulus(assigns)
  end
end
