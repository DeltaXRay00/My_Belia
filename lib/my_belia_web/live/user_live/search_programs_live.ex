defmodule MyBeliaWeb.UserLive.SearchProgramsLive do
  use MyBeliaWeb, :live_view

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok, assign(socket, current_user: current_user, query: "", programs: [], page_title: "Carian Program"), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.search_programs(assigns)
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) >= 2 do
      programs = MyBelia.Programs.search_programs(query)
      {:noreply, assign(socket, query: query, programs: programs)}
    else
      {:noreply, assign(socket, query: "", programs: [])}
    end
  end
end
