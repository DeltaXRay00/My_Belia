defmodule MyBeliaWeb.AdminLive.AdminPermohonanProgramLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    programs = MyBelia.Programs.list_programs()
    {:ok, assign(socket, programs: programs)}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_program(assigns)
  end
end
