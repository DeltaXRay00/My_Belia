defmodule MyBeliaWeb.UserLive.SearchProgramsLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", programs: [], loading: false)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) >= 2 do
      programs = MyBelia.Programs.search_programs(query)
      {:noreply, assign(socket, query: query, programs: programs, loading: false)}
    else
      {:noreply, assign(socket, query: query, programs: [], loading: false)}
    end
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, assign(socket, query: "", programs: [], loading: false)}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.search_programs(assigns)
  end
end
