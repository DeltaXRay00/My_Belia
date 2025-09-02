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
       page_title: "Pemohon Kursus - #{course.name}",
       selected_application: nil,
       user_documents: [],
       user_education: nil,
       show_view_modal: false
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

    def handle_event("view-application", %{"application_id" => application_id}, socket) do
    try do
            application = CourseApplications.get_course_application!(application_id)
      application = MyBelia.Repo.preload(application, [:user])

      # Get user documents and education details
      user_documents = MyBelia.Documents.get_user_documents(application.user_id)
      user_educations = MyBelia.Accounts.get_user_educations(application.user_id)

      # Build combined education entries: explicit records + user-level fallback
      user_level_entry =
        if application.user.education_level || application.user.field_of_study || application.user.course || application.user.institution || application.user.graduation_date do
          [%{
            education_level: application.user.education_level,
            field_of_study: application.user.field_of_study,
            course: application.user.course,
            institution: application.user.institution,
            graduation_date: application.user.graduation_date
          }]
        else
          []
        end

      explicit_entries = Enum.map(user_educations, fn ue ->
        %{
          education_level: ue.education_level,
          field_of_study: ue.field_of_study,
          course: ue.course,
          institution: ue.institution,
          graduation_date: ue.graduation_date
        }
      end)

      education_entries =
        (explicit_entries ++ user_level_entry)
        |> Enum.sort_by(fn e ->
          days = if e.graduation_date, do: Date.to_gregorian_days(e.graduation_date), else: 0
          {rank_level(e.education_level), -days}
        end)

      {:noreply,
       socket
       |> assign(:selected_application, application)
       |> assign(:user_documents, user_documents)
       |> assign(:user_education, nil)
       |> assign(:user_educations, user_educations)
       |> assign(:education_entries, education_entries)
       |> assign(:show_view_modal, true)}
    rescue
      e ->
        IO.inspect(e, label: "Error in view-application")
        {:noreply, put_flash(socket, :error, "Ralat semasa memuat maklumat pemohon.")}
    end
  end

  def handle_event("close-view-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_view_modal, false)
     |> assign(:selected_application, nil)
     |> assign(:user_documents, [])
     |> assign(:user_education, nil)
     |> assign(:user_educations, [])
     |> assign(:education_entries, [])}
  end

  defp rank_level(nil), do: 99
  defp rank_level(level) when is_binary(level) do
    case String.downcase(String.trim(level)) do
      "phd" -> 0
      "doktor falsafah" -> 0
      "sarjana" -> 1
      "master" -> 1
      "sarjana muda" -> 2
      "ijazah sarjana muda" -> 2
      "ijazah" -> 2
      "bachelor" -> 2
      "diploma" -> 3
      "stpm" -> 4
      "matrikulasi" -> 4
      "spm" -> 5
      _ -> 50
    end
  end
end
