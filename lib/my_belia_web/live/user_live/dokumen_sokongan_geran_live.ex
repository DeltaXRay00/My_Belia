defmodule MyBeliaWeb.UserLive.DokumenSokonganGeranLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan_geran(assigns)
  end
end
