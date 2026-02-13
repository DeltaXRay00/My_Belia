defmodule MyBeliaWeb.AdminLive.AdminLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    programs = safe_list(&MyBelia.Programs.list_programs/0)
    courses = safe_list(&MyBelia.Courses.list_courses/0)

    recent_programs = Enum.take(programs, 3)
    recent_courses = Enum.take(courses, 3)

    activities =
      Enum.map(recent_programs, fn p -> %{type: :program, title: p.name, date: Map.get(p, :start_date)} end) ++
      Enum.map(recent_courses, fn c -> %{type: :kursus, title: c.name, date: Map.get(c, :start_date)} end)
      |> Enum.take(6)

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Admin Dashboard",
       stat_belia: 14,
       stat_program: 1,
       stat_kursus: 1,
       stat_permohonan: 3,
       activities: activities
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin(assigns)
  end

  defp safe_list(fun) do
    try do
      fun.()
    rescue
      _ -> []
    end
  end
end
