defmodule MyBeliaWeb.AdminLive.AdminPermohonanProgramLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.Programs

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    programs = Programs.list_programs()

    # Get program application counts for each program
    program_applications_counts = Enum.reduce(programs, %{}, fn program, acc ->
      count = ProgramApplications.get_program_applications_count(program.id)
      Map.put(acc, program.id, count)
    end)

    {:ok,
     assign(socket,
       current_user: current_user,
       programs: programs,
       program_applications_counts: program_applications_counts,
       page_title: "Admin Permohonan Program"
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_program(assigns)
  end

  def handle_event("review-application", %{"application_id" => application_id, "status" => status, "notes" => notes}, socket) do
    current_user = socket.assigns.current_user

    case ProgramApplications.update_application_status(application_id, status, current_user.id, notes) do
      {:ok, _application} ->
        # Refresh the applications list
        program_applications = ProgramApplications.list_program_applications_with_details()

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
    case filter do
      "all" ->
        program_applications = ProgramApplications.list_program_applications_with_details()
        {:noreply, assign(socket, program_applications: program_applications)}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        program_applications = ProgramApplications.list_program_applications_by_status(status)
        {:noreply, assign(socket, program_applications: program_applications)}

      _ ->
        {:noreply, socket}
    end
  end
end
