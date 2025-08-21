defmodule MyBeliaWeb.UserLive.UserProfileLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.user_profile(assigns)
  end
end
