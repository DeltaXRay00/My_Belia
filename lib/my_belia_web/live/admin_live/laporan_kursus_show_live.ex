defmodule MyBeliaWeb.AdminLive.LaporanKursusShowLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.CourseLogs

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    {:ok, assign(socket, current_user: current_user, page_title: "Laporan Kursus"), layout: false}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    course_log = CourseLogs.get_course_log!(id)
    {:noreply, assign(socket, course_log: course_log)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    MyBeliaWeb.CourseLogHTML.show(assigns)
  end
end
