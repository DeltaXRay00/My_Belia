defmodule MyBeliaWeb.UserLive.SenaraiKursusLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    courses = MyBelia.Courses.list_courses()
    {:ok, assign(socket, courses: courses)}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_kursus(assigns)
  end
end
