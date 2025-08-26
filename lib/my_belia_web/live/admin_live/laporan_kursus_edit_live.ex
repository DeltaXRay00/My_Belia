defmodule MyBeliaWeb.AdminLive.LaporanKursusEditLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.CourseLogs

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok, assign(socket, current_user: current_user, page_title: "Kemaskini Laporan Kursus"),
     layout: false}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    course_log = CourseLogs.get_course_log!(id)
    changeset = CourseLogs.change_course_log(course_log)
    {:noreply, assign(socket, course_log: course_log, changeset: changeset)}
  end

  def handle_event("save", %{"course_log" => course_log_params}, socket) do
    course_log = socket.assigns.course_log

    case CourseLogs.update_course_log(course_log, course_log_params) do
      {:ok, course_log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course log updated successfully.")
         |> push_navigate(to: ~p"/laporan_kursus/#{course_log}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    MyBeliaWeb.CourseLogHTML.edit(assigns)
  end
end
