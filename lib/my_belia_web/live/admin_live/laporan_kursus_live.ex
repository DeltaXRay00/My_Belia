defmodule MyBeliaWeb.AdminLive.LaporanKursusLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.CourseLogs

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    course_logs = CourseLogs.list_course_logs()
    {:ok, assign(socket, course_logs: course_logs, current_user: current_user, page_title: "Laporan Kursus"), layout: false}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    course_log = CourseLogs.get_course_log!(id)
    {:noreply, assign(socket, course_log: course_log)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    course_log = CourseLogs.get_course_log!(id)
    {:ok, _} = CourseLogs.delete_course_log(course_log)

    {:noreply,
     socket
     |> put_flash(:info, "Course log deleted successfully.")
     |> push_navigate(to: ~p"/laporan_kursus")}
  end

  def render(assigns) do
    MyBeliaWeb.CourseLogHTML.index(assigns)
  end
end
