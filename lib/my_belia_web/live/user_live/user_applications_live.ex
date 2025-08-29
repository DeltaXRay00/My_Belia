defmodule MyBeliaWeb.UserLive.UserApplicationsLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.CourseApplications

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    if current_user do
      # Get user's program and course applications
      program_applications = ProgramApplications.get_user_program_applications(current_user.id)
      course_applications = CourseApplications.get_user_course_applications(current_user.id)

      {:ok,
       assign(socket,
         current_user: current_user,
         program_applications: program_applications,
         course_applications: course_applications,
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

    case filter do
      "all" ->
        program_applications = ProgramApplications.get_user_program_applications(user_id)
        course_applications = CourseApplications.get_user_course_applications(user_id)
        {:noreply, assign(socket, program_applications: program_applications, course_applications: course_applications)}

      "programs" ->
        program_applications = ProgramApplications.get_user_program_applications(user_id)
        {:noreply, assign(socket, program_applications: program_applications, course_applications: [])}

      "courses" ->
        course_applications = CourseApplications.get_user_course_applications(user_id)
        {:noreply, assign(socket, program_applications: [], course_applications: course_applications)}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        program_applications = ProgramApplications.get_user_program_applications_by_status(user_id, status)
        course_applications = CourseApplications.get_user_course_applications_by_status(user_id, status)
        {:noreply, assign(socket, program_applications: program_applications, course_applications: course_applications)}

      _ ->
        {:noreply, socket}
    end
  end
end
