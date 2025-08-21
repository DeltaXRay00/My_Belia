defmodule MyBeliaWeb.UserLive.SearchCoursesLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", courses: [], loading: false)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) >= 2 do
      courses = MyBelia.Courses.search_courses(query)
      {:noreply, assign(socket, query: query, courses: courses, loading: false)}
    else
      {:noreply, assign(socket, query: query, courses: [], loading: false)}
    end
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, assign(socket, query: "", courses: [], loading: false)}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.search_courses(assigns)
  end
end
