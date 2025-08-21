defmodule MyBeliaWeb.AdminLive.CourseManagementLive do
  use MyBeliaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Course Management"), layout: false}
  end

  def handle_event("create_course", %{"course" => course_params}, socket) do
    case MyBelia.Courses.create_course(course_params) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kursus berjaya dicipta!")
         |> assign(:courses, MyBelia.Courses.list_courses())}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat dalam mencipta kursus.")
         |> assign(:error, format_changeset_errors(changeset))}
    end
  end

  def handle_event("update_course", %{"id" => id, "course" => course_params}, socket) do
    course = MyBelia.Courses.get_course!(id)
    case MyBelia.Courses.update_course(course, course_params) do
      {:ok, _updated_course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kursus berjaya dikemas kini!")
         |> assign(:courses, MyBelia.Courses.list_courses())}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat dalam mengemas kini kursus.")
         |> assign(:error, format_changeset_errors(changeset))}
    end
  rescue
    Ecto.QueryError ->
      {:noreply,
       socket
       |> put_flash(:error, "Kursus tidak dijumpai")}
  end

  def handle_event("get_course", %{"id" => id}, socket) do
    case MyBelia.Courses.get_course!(id) do
      course ->
        {:noreply, assign(socket, selected_course: course)}
    end
  rescue
    Ecto.QueryError ->
      {:noreply,
       socket
       |> put_flash(:error, "Kursus tidak dijumpai")}
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_kursus(assigns)
  end
end
