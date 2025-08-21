defmodule MyBeliaWeb.UserLive.SkimGeranLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok, assign(socket, current_user: current_user, page_title: "Skim Geran"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.skim_geran(assigns)
  end
end
