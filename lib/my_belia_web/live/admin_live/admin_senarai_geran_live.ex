defmodule MyBeliaWeb.AdminLive.AdminSenaraiGeranLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Senarai Geran"
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_geran(assigns)
  end
end
