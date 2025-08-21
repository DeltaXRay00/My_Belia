defmodule MyBeliaWeb.UserLive.PermohonanGeranLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.permohonan_geran(assigns)
  end
end
