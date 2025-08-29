defmodule MyBeliaWeb.AdminLive.AdminCoursePemohonLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.CourseApplications
  alias MyBelia.Courses

  def mount(%{"id" => course_id}, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    course = Courses.get_course!(course_id)
    course_applications = CourseApplications.get_course_applications_with_details(course_id)

    {:ok,
     assign(socket,
       current_user: current_user,
       course: course,
       course_applications: course_applications,
       current_filter: "all",
       page_title: "Pemohon Kursus - #{course.name}"
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_course_pemohon(assigns)
  end

  def handle_event("review-application", %{"application_id" => application_id, "status" => status, "notes" => notes}, socket) do
    current_user = socket.assigns.current_user

    case CourseApplications.update_application_status(application_id, status, current_user.id, notes) do
      {:ok, _application} ->
        # Refresh the applications list
        course_applications = CourseApplications.get_course_applications_with_details(socket.assigns.course.id)

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
    course_id = socket.assigns.course.id

    case filter do
      "all" ->
        course_applications = CourseApplications.get_course_applications_with_details(course_id)
        {:noreply, assign(socket, course_applications: course_applications, current_filter: "all")}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        course_applications = CourseApplications.get_course_applications_by_status(course_id, status)
        {:noreply, assign(socket, course_applications: course_applications, current_filter: status)}

      _ ->
        {:noreply, socket}
    end
  end
end
