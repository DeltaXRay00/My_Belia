defmodule MyBeliaWeb.UserLive.SenaraiProgramLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    programs = MyBelia.Programs.list_programs()

    {:ok, assign(socket, current_user: current_user, programs: programs, page_title: "Senarai Program"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_program(assigns)
  end
end
