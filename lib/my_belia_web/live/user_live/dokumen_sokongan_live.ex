defmodule MyBeliaWeb.UserLive.DokumenSokonganLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan(assigns)
  end
end
