defmodule MyBeliaWeb.AdminLive.PemohonLulusLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Pemohon Lulus"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pemohon_lulus(assigns)
  end
end
