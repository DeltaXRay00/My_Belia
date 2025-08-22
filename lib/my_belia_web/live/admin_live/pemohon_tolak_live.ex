defmodule MyBeliaWeb.AdminLive.PemohonTolakLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Pemohon Tolak"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pemohon_tolak(assigns)
  end
end
