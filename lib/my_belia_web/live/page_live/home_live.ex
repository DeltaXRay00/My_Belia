defmodule MyBeliaWeb.PageLive.HomeLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.home(assigns)
  end
end
