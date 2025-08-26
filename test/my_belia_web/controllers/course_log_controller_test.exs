defmodule MyBeliaWeb.CourseLogControllerTest do
  use MyBeliaWeb.ConnCase

  import MyBelia.CourseLogsFixtures

  alias MyBelia.CourseLogs.CourseLog

  @create_attrs %{
    title: "some title",
    description: "some description",
    status: "some status",
    course_id: 42,
    instructor_id: 42
  }
  @update_attrs %{
    title: "some updated title",
    description: "some updated description",
    status: "some updated status",
    course_id: 43,
    instructor_id: 43
  }
  @invalid_attrs %{title: nil, description: nil, status: nil, course_id: nil, instructor_id: nil}

  def fixture(:course_log) do
    course_log_fixture()
  end

  describe "index" do
    test "lists all course_logs", %{conn: conn} do
      conn = get(conn, ~p"/log_kursus/laporan")
      assert html_response(conn, 200) =~ "Log Kursus"
    end
  end

  describe "new course_log" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/log_kursus/laporan/new")
      assert html_response(conn, 200) =~ "New Course Log"
    end
  end

  describe "create course_log" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/log_kursus/laporan", course_log: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/log_kursus/laporan/#{id}"

      conn = get(conn, ~p"/log_kursus/laporan/#{id}")
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/log_kursus/laporan", course_log: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Course Log"
    end
  end

  describe "show course_log" do
    setup [:create_course_log]

    test "displays course_log", %{conn: conn, course_log: course_log} do
      conn = get(conn, ~p"/log_kursus/laporan/#{course_log}")
      assert html_response(conn, 200) =~ course_log.title
    end
  end

  describe "edit course_log" do
    setup [:create_course_log]

    test "renders form for editing chosen course_log", %{conn: conn, course_log: course_log} do
      conn = get(conn, ~p"/log_kursus/laporan/#{course_log}/edit")
      assert html_response(conn, 200) =~ "Edit Course Log"
    end
  end

  describe "update course_log" do
    setup [:create_course_log]

    test "redirects when data is valid", %{conn: conn, course_log: course_log} do
      conn = put(conn, ~p"/log_kursus/laporan/#{course_log}", course_log: @update_attrs)
      assert redirected_to(conn) == ~p"/log_kursus/laporan/#{course_log}"

      conn = get(conn, ~p"/log_kursus/laporan/#{course_log}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, course_log: course_log} do
      conn = put(conn, ~p"/log_kursus/laporan/#{course_log}", course_log: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course Log"
    end
  end

  describe "delete course_log" do
    setup [:create_course_log]

    test "deletes chosen course_log", %{conn: conn, course_log: course_log} do
      conn = delete(conn, ~p"/log_kursus/laporan/#{course_log}")
      assert redirected_to(conn) == ~p"/log_kursus/laporan"

      assert_error_sent 404, fn ->
        get(conn, ~p"/log_kursus/laporan/#{course_log}")
      end
    end
  end

  defp create_course_log(_) do
    course_log = fixture(:course_log)
    %{course_log: course_log}
  end
end
