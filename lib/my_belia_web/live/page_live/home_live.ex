defmodule MyBeliaWeb.PageLive.HomeLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    programs = safe_list(&MyBelia.Programs.list_programs/0)
    courses = safe_list(&MyBelia.Courses.list_courses/0)
    grants = safe_list(&MyBelia.Grants.list_grants/0)

    {:ok,
     socket
     |> assign(:quick_programs, Enum.take(programs, 2))
     |> assign(:quick_courses, Enum.take(courses, 2))
     |> assign(:quick_grants, Enum.take(grants, 2)),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.home(assigns)
  end

  defp safe_list(fun) do
    try do
      fun.()
    rescue
      _ -> []
    end
  end
end
