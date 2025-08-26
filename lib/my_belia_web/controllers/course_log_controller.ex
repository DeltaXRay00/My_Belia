defmodule MyBeliaWeb.CourseLogController do
  use MyBeliaWeb, :controller

  alias MyBelia.CourseLogs
  alias MyBelia.CourseLogs.CourseLog

  def index(conn, _params) do
    course_logs = CourseLogs.list_course_logs()
    conn
    |> put_layout(false)
    |> render("index.html", course_logs: course_logs)
  end

  def new(conn, _params) do
    changeset = CourseLogs.change_course_log(%CourseLog{})
    conn
    |> put_layout(false)
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"course_log" => course_log_params}) do
    case CourseLogs.create_course_log(course_log_params) do
      {:ok, course_log} ->
        conn
        |> put_flash(:info, "Course log created successfully.")
        |> redirect(to: ~p"/laporan_kursus/#{course_log}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
    |> put_layout(false)
    |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course_log = CourseLogs.get_course_log!(id)
    conn
    |> put_layout(false)
    |> render("show.html", course_log: course_log)
  end

  def edit(conn, %{"id" => id}) do
    course_log = CourseLogs.get_course_log!(id)
    changeset = CourseLogs.change_course_log(course_log)
    conn
    |> put_layout(false)
    |> render("edit.html", course_log: course_log, changeset: changeset)
  end

  def update(conn, %{"id" => id, "course_log" => course_log_params}) do
    course_log = CourseLogs.get_course_log!(id)

    case CourseLogs.update_course_log(course_log, course_log_params) do
      {:ok, course_log} ->
        conn
        |> put_flash(:info, "Course log updated successfully.")
        |> redirect(to: ~p"/laporan_kursus/#{course_log}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
    |> put_layout(false)
    |> render("edit.html", course_log: course_log, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    course_log = CourseLogs.get_course_log!(id)
    {:ok, _course_log} = CourseLogs.delete_course_log(course_log)

    conn
    |> put_flash(:info, "Course log deleted successfully.")
    |> redirect(to: ~p"/laporan_kursus")
  end
end
