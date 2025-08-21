defmodule MyBeliaWeb.UserLive.SearchLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: [], loading: false)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) >= 2 do
      # Real-time search across programs, courses, and grants
      results = perform_search(query)
      {:noreply, assign(socket, query: query, results: results, loading: false)}
    else
      {:noreply, assign(socket, query: query, results: [], loading: false)}
    end
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, assign(socket, query: "", results: [], loading: false)}
  end

  defp perform_search(query) do
    # Search in programs
    programs = MyBelia.Programs.search_programs(query)
    # Search in courses
    courses = MyBelia.Courses.search_courses(query)
    # Search in grants (if you have a grants module)
    # grants = MyBelia.Grants.search_grants(query)

    %{
      programs: programs,
      courses: courses,
      # grants: grants
    }
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.search_results(assigns)
  end
end
