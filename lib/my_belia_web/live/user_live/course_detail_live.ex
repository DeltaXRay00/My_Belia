defmodule MyBeliaWeb.UserLive.CourseDetailLive do
  use MyBeliaWeb, :live_view

  def mount(%{"id" => id}, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    course = MyBelia.Courses.get_course!(id)

    {:ok, assign(socket, current_user: current_user, course: course, page_title: course.name), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.course_detail(assigns)
  end
end
