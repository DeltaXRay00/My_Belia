defmodule MyBeliaWeb.AdminLive.PemohonTidakLengkapLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Pemohon Tidak Lengkap"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pemohon_tidak_lengkap(assigns)
  end
end
