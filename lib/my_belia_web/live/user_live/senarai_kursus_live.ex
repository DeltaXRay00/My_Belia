defmodule MyBeliaWeb.UserLive.SenaraiKursusLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    courses = MyBelia.Courses.list_courses()

    {:ok, assign(socket, current_user: current_user, courses: courses, page_title: "Senarai Kursus"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_kursus(assigns)
  end
end
