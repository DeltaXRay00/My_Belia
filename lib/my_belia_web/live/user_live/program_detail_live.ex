defmodule MyBeliaWeb.UserLive.ProgramDetailLive do
  use MyBeliaWeb, :live_view

  def mount(%{"id" => id}, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    program = MyBelia.Programs.get_program!(id)

    {:ok, assign(socket, current_user: current_user, program: program, page_title: program.name), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.program_detail(assigns)
  end
end
