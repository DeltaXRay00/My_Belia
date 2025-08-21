defmodule MyBeliaWeb.UserLive.SkimGeranLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.skim_geran(assigns)
  end
end
