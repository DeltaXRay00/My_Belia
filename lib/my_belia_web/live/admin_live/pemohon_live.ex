defmodule MyBeliaWeb.AdminLive.PemohonLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Pemohon"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pemohon(assigns)
  end
end
