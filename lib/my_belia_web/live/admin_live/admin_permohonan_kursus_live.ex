defmodule MyBeliaWeb.AdminLive.AdminPermohonanKursusLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.CourseApplications
  alias MyBelia.Courses

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    courses = Courses.list_courses()

    # Get course application counts for each course
    course_applications_counts = Enum.reduce(courses, %{}, fn course, acc ->
      count = CourseApplications.get_course_applications_count(course.id)
      Map.put(acc, course.id, count)
    end)

    {:ok,
     assign(socket,
       current_user: current_user,
       courses: courses,
       course_applications_counts: course_applications_counts,
       page_title: "Admin Permohonan Kursus"
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_kursus(assigns)
  end

  def handle_event("review-application", %{"application_id" => application_id, "status" => status, "notes" => notes}, socket) do
    current_user = socket.assigns.current_user

    case CourseApplications.update_application_status(application_id, status, current_user.id, notes) do
      {:ok, _application} ->
        # Refresh the applications list
        course_applications = CourseApplications.list_course_applications_with_details()

        status_text = case status do
          "diluluskan" -> "Diluluskan"
          "ditolak" -> "Ditolak"
          "tidak_lengkap" -> "Tidak Lengkap"
          _ -> status
        end

        {:noreply,
         socket
         |> assign(course_applications: course_applications)
         |> put_flash(:info, "Permohonan telah #{status_text}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Ralat semasa mengemas kini status permohonan.")}
    end
  end

  def handle_event("filter-applications", %{"filter" => filter}, socket) do
    case filter do
      "all" ->
        course_applications = CourseApplications.list_course_applications_with_details()
        {:noreply, assign(socket, course_applications: course_applications)}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        course_applications = CourseApplications.list_course_applications_by_status(status)
        {:noreply, assign(socket, course_applications: course_applications)}

      _ ->
        {:noreply, socket}
    end
  end
end
