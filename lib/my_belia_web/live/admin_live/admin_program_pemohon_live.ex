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
       page_title: "Pemohon Program - #{program.name}"
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
end
