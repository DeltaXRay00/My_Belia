defmodule MyBeliaWeb.AdminLive.AdminProgramPemohonLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.Programs

  def mount(%{"id" => program_id}, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    program = Programs.get_program!(program_id)
    program_applications = ProgramApplications.get_program_applications_with_details(program_id)

    {:ok,
     assign(socket,
       current_user: current_user,
       program: program,
       program_applications: program_applications,
       current_filter: "all",
       page_title: "Pemohon Program - #{program.name}",
       selected_application: nil,
       user_documents: [],
       user_education: nil,
       show_view_modal: false,
       show_status_confirmation: false,
       status_change_application_id: nil,
       status_change_new_status: nil,
       status_change_current_status: nil,
       open_dropdown_id: nil
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_program_pemohon(assigns)
  end

  def handle_event("review-application", %{"application_id" => application_id, "status" => status, "notes" => notes}, socket) do
    current_user = socket.assigns.current_user

    case ProgramApplications.update_application_status(application_id, status, current_user.id, notes) do
      {:ok, _application} ->
        # Refresh the applications list
        program_applications = ProgramApplications.get_program_applications_with_details(socket.assigns.program.id)

        status_text = case status do
          "diluluskan" -> "Diluluskan"
          "ditolak" -> "Ditolak"
          "tidak_lengkap" -> "Tidak Lengkap"
          _ -> status
        end

        {:noreply,
         socket
         |> assign(program_applications: program_applications)
         |> put_flash(:info, "Permohonan telah #{status_text}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Ralat semasa mengemas kini status permohonan.")}
    end
  end

  def handle_event("filter-applications", %{"filter" => filter}, socket) do
    program_id = socket.assigns.program.id

    case filter do
      "all" ->
        program_applications = ProgramApplications.get_program_applications_with_details(program_id)
        {:noreply, assign(socket, program_applications: program_applications, current_filter: "all")}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        program_applications = ProgramApplications.get_program_applications_by_status(program_id, status)
        {:noreply, assign(socket, program_applications: program_applications, current_filter: status)}

      _ ->
        {:noreply, socket}
    end
  end

    def handle_event("view-application", %{"application_id" => application_id}, socket) do
    try do
            application = ProgramApplications.get_program_application!(application_id)
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

    def handle_event("toggle-status-dropdown", %{"dropdown_id" => dropdown_id}, socket) do
    # Toggle the dropdown visibility
    current_open = socket.assigns.open_dropdown_id

    if current_open == dropdown_id do
      # Close the current dropdown
      {:noreply, assign(socket, :open_dropdown_id, nil)}
    else
      # Open the new dropdown (close any other open dropdown)
      {:noreply, assign(socket, :open_dropdown_id, dropdown_id)}
    end
  end

  def handle_event("select-new-status", %{"application_id" => application_id, "new_status" => new_status}, socket) do
    # Find the current application to get its current status
    current_application = Enum.find(socket.assigns.program_applications, &(&1.id == application_id))
    current_status = if current_application, do: current_application.status, else: "menunggu"

    {:noreply,
     socket
     |> assign(:status_change_application_id, application_id)
     |> assign(:status_change_new_status, new_status)
     |> assign(:status_change_current_status, current_status)
     |> assign(:show_status_confirmation, true)}
  end

  def handle_event("confirm-status-change", _params, socket) do
    application_id = socket.assigns.status_change_application_id
    new_status = socket.assigns.status_change_new_status
    current_user = socket.assigns.current_user

    case ProgramApplications.update_application_status(application_id, new_status, current_user.id, nil) do
      {:ok, _application} ->
        # Close the modal and clear status change data
        socket = socket
        |> assign(:show_status_confirmation, false)
        |> assign(:status_change_application_id, nil)
        |> assign(:status_change_new_status, nil)
        |> assign(:status_change_current_status, nil)
        |> assign(:open_dropdown_id, nil)  # Close any open dropdowns

        # Refresh the applications list based on current filter
        program_id = socket.assigns.program.id
        program_applications = case socket.assigns.current_filter do
          "all" -> ProgramApplications.get_program_applications_with_details(program_id)
          status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
            # If we're on a specific status tab, filter by that status
            ProgramApplications.get_program_applications_by_status(program_id, status)
          _ -> ProgramApplications.get_program_applications_with_details(program_id)
        end

        status_text = case new_status do
          "diluluskan" -> "Lulus"
          "ditolak" -> "Tolak"
          "tidak_lengkap" -> "Tidak Lengkap"
          "menunggu" -> "Menunggu"
          _ -> new_status
        end

        # Update the applications list
        socket = assign(socket, :program_applications, program_applications)

        {:noreply,
         socket
         |> put_flash(:info, "Status permohonan telah berjaya diubah kepada #{status_text}. Sekarang anda boleh lihat permohonan ini dalam tab '#{status_text}'.")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:show_status_confirmation, false)
         |> assign(:status_change_application_id, nil)
         |> assign(:status_change_new_status, nil)
         |> assign(:status_change_current_status, nil)
         |> put_flash(:error, "Ralat semasa mengemas kini status permohonan.")}
    end
  end

  def handle_event("cancel-status-change", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_status_confirmation, false)
     |> assign(:status_change_application_id, nil)
     |> assign(:status_change_new_status, nil)
     |> assign(:status_change_current_status, nil)}
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
