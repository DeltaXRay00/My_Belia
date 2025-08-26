defmodule MyBeliaWeb.AdminLive.LaporanKursusNewLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.CourseLogs
  alias MyBelia.CourseLogs.CourseLog

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    changeset = CourseLogs.change_course_log(%CourseLog{})

    {:ok,
     assign(socket,
       changeset: changeset,
       current_user: current_user,
       page_title: "Laporan Kursus Baharu"
     ), layout: false}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"course_log" => course_log_params}, socket) do
    case CourseLogs.create_course_log(course_log_params) do
      {:ok, course_log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course log created successfully.")
         |> push_navigate(to: ~p"/laporan_kursus/#{course_log}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    MyBeliaWeb.CourseLogHTML.new(assigns)
  end
end
