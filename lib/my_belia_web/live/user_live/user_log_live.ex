defmodule MyBeliaWeb.UserLive.UserLogLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.CourseApplications

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    if current_user do
      # Get user's program and course applications with full details
      program_applications = ProgramApplications.get_user_program_applications_with_details(current_user.id)
      course_applications = CourseApplications.get_user_course_applications_with_details(current_user.id)

      # Combine and sort all activities by date
      all_activities = build_activity_timeline(program_applications, course_applications)

      {:ok,
       assign(socket,
         current_user: current_user,
         program_applications: program_applications,
         course_applications: course_applications,
         all_activities: all_activities,
         page_title: "Log Aktiviti"
       ),
       layout: false}
    else
      {:ok, redirect(socket, to: "/log-masuk")}
    end
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.user_log(assigns)
  end

  def handle_event("filter-activities", %{"filter" => filter}, socket) do
    user_id = socket.assigns.current_user.id

    case filter do
      "all" ->
        program_applications = ProgramApplications.get_user_program_applications_with_details(user_id)
        course_applications = CourseApplications.get_user_course_applications_with_details(user_id)
        all_activities = build_activity_timeline(program_applications, course_applications)
        {:noreply, assign(socket, all_activities: all_activities)}

      "applications" ->
        program_applications = ProgramApplications.get_user_program_applications_with_details(user_id)
        course_applications = CourseApplications.get_user_course_applications_with_details(user_id)
        all_activities = build_activity_timeline(program_applications, course_applications)
        {:noreply, assign(socket, all_activities: all_activities)}

      "reviews" ->
        program_applications = ProgramApplications.get_user_program_applications_with_details(user_id)
        course_applications = CourseApplications.get_user_course_applications_with_details(user_id)
        all_activities = build_activity_timeline(program_applications, course_applications)
        # Filter to only show review activities
        review_activities = Enum.filter(all_activities, fn activity ->
          activity.type == "review"
        end)
        {:noreply, assign(socket, all_activities: review_activities)}

      _ ->
        {:noreply, socket}
    end
  end

  defp build_activity_timeline(program_applications, course_applications) do
    activities = []

    # Add program application activities
    activities = activities ++ Enum.map(program_applications, fn app ->
      %{
        id: "program_#{app.id}",
        type: "application",
        title: "Permohonan Program: #{app.program.name}",
        description: "Anda telah memohon untuk program #{app.program.name}",
        date: app.application_date,
        status: app.status,
        category: "program",
        application: app
      }
    end)

    # Add course application activities
    activities = activities ++ Enum.map(course_applications, fn app ->
      %{
        id: "course_#{app.id}",
        type: "application",
        title: "Permohonan Kursus: #{app.course.name}",
        description: "Anda telah memohon untuk kursus #{app.course.name}",
        date: app.application_date,
        status: app.status,
        category: "course",
        application: app
      }
    end)

    # Add review activities (if reviewed)
    activities = activities ++ Enum.flat_map(program_applications, fn app ->
      if app.review_date do
        [%{
          id: "program_review_#{app.id}",
          type: "review",
          title: "Semakan Permohonan Program: #{app.program.name}",
          description: "Permohonan anda untuk program #{app.program.name} telah disemak",
          date: app.review_date,
          status: app.status,
          category: "program",
          application: app,
          reviewer: app.reviewed_by
        }]
      else
        []
      end
    end)

    activities = activities ++ Enum.flat_map(course_applications, fn app ->
      if app.review_date do
        [%{
          id: "course_review_#{app.id}",
          type: "review",
          title: "Semakan Permohonan Kursus: #{app.course.name}",
          description: "Permohonan anda untuk kursus #{app.course.name} telah disemak",
          date: app.review_date,
          status: app.status,
          category: "course",
          application: app,
          reviewer: app.reviewed_by
        }]
      else
        []
      end
    end)

    # Sort by date (newest first)
    Enum.sort_by(activities, & &1.date, {:desc, Date})
  end
end
