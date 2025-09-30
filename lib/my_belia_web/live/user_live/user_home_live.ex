defmodule MyBeliaWeb.UserLive.UserHomeLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    programs = safe_list(&MyBelia.Programs.list_programs/0)
    courses = safe_list(&MyBelia.Courses.list_courses/0)
    grants = safe_list(&MyBelia.Grants.list_grants/0)

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Laman Utama Pengguna",
       quick_programs: Enum.take(programs, 2),
       quick_courses: Enum.take(courses, 2),
       quick_grants: Enum.take(grants, 2)
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.user_home(assigns)
  end

  defp safe_list(fun) do
    try do
      fun.()
    rescue
      _ -> []
    end
  end
end
