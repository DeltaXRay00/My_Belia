defmodule MyBeliaWeb.UserLive.UserApplicationsLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.CourseApplications
  alias MyBelia.GrantApplications

  def mount(_params, session, socket) do
    session_user_id = session["user_id"]
    socket_user_id = case Map.fetch(socket.assigns, :current_user) do
      {:ok, %{id: id}} -> id
      _ -> nil
    end

    user_id = session_user_id || socket_user_id
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    if current_user do
      # Unfiltered totals for stable counters
      all_programs = ProgramApplications.get_user_program_applications(current_user.id)
      all_courses = CourseApplications.get_user_course_applications(current_user.id)
      all_grants = GrantApplications.get_user_grant_applications(current_user.id)

      {:ok,
       assign(socket,
         current_user: current_user,
         program_applications: all_programs,
         course_applications: all_courses,
         grant_applications: all_grants,
         total_program_applications: length(all_programs),
         total_course_applications: length(all_courses),
         total_grant_applications: length(all_grants),
         current_filter: "all",
         page_title: "Permohonan Saya"
       ),
       layout: false}
    else
      {:ok, redirect(socket, to: "/log-masuk")}
    end
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.user_applications(assigns)
  end

  def handle_event("filter-applications", %{"filter" => filter}, socket) do
    user_id = socket.assigns.current_user.id

    all_programs = ProgramApplications.get_user_program_applications(user_id)
    all_courses = CourseApplications.get_user_course_applications(user_id)
    all_grants = GrantApplications.get_user_grant_applications(user_id)

    normalized = case filter do
      # normalize Malay statuses to internal values where needed
      "menunggu" -> "menunggu"
      "diluluskan" -> "diluluskan"
      "ditolak" -> "ditolak"
      "tidak_lengkap" -> "tidak_lengkap"
      other -> other
    end

    {program_applications, course_applications, grant_applications} =
      case normalized do
        "all" -> {all_programs, all_courses, all_grants}
        "programs" -> {all_programs, [], []}
        "courses" -> {[], all_courses, []}
        "grants" -> {[], [], all_grants}
        status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
          {
            Enum.filter(all_programs, &(&1.status == status)),
            Enum.filter(all_courses, &(&1.status == status)),
            Enum.filter(all_grants, &(&1.status == status))
          }
        _ -> {socket.assigns.program_applications, socket.assigns.course_applications, socket.assigns.grant_applications}
      end

    {:noreply,
     assign(socket,
       program_applications: program_applications,
       course_applications: course_applications,
       grant_applications: grant_applications,
       total_program_applications: length(all_programs),
       total_course_applications: length(all_courses),
       total_grant_applications: length(all_grants),
       current_filter: filter
     )}
  end
end
