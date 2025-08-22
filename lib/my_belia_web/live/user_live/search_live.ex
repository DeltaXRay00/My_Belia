defmodule MyBeliaWeb.UserLive.SearchLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok, assign(socket, current_user: current_user, query: "", results: [], loading: false, page_title: "Carian"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.search_results(assigns)
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) >= 2 do
      # Search in programs
      programs = MyBelia.Programs.search_programs(query)
      # Search in courses
      courses = MyBelia.Courses.search_courses(query)

      results = %{
        programs: programs,
        courses: courses
      }

      {:noreply, assign(socket, query: query, results: results, loading: false)}
    else
      {:noreply, assign(socket, query: "", results: [], loading: false)}
    end
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, assign(socket, query: "", results: [], loading: false)}
  end
end
