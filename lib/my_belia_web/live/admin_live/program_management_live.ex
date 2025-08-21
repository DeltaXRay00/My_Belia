defmodule MyBeliaWeb.AdminLive.ProgramManagementLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Program Management"), layout: false}
  end

  def handle_event("create_program", %{"program" => program_params}, socket) do
    case MyBelia.Programs.create_program(program_params) do
      {:ok, _program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program berjaya dicipta!")
         |> assign(:programs, MyBelia.Programs.list_programs())}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat dalam mencipta program.")
         |> assign(:error, format_changeset_errors(changeset))}
    end
  end

  def handle_event("update_program", %{"id" => id, "program" => program_params}, socket) do
    program = MyBelia.Programs.get_program!(id)
    case MyBelia.Programs.update_program(program, program_params) do
      {:ok, _updated_program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program berjaya dikemas kini!")
         |> assign(:programs, MyBelia.Programs.list_programs())}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat dalam mengemas kini program.")
         |> assign(:error, format_changeset_errors(changeset))}
    end
  rescue
    Ecto.QueryError ->
      {:noreply,
       socket
       |> put_flash(:error, "Program tidak dijumpai")}
  end

  def handle_event("get_program", %{"id" => id}, socket) do
    case MyBelia.Programs.get_program!(id) do
      program ->
        {:noreply, assign(socket, selected_program: program)}
    end
  rescue
    Ecto.QueryError ->
      {:noreply,
       socket
       |> put_flash(:error, "Program tidak dijumpai")}
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_program(assigns)
  end
end
