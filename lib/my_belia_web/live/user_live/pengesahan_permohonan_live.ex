defmodule MyBeliaWeb.UserLive.PengesahanPermohonanLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pengesahan_permohonan(assigns)
  end
end
