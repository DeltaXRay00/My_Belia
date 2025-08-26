defmodule MyBeliaWeb.ProgramLogControllerTest do
  use MyBeliaWeb.ConnCase

  import MyBelia.ReportsFixtures

  alias MyBelia.Reports.Report

  @create_attrs %{title: "some title", description: "some description", status: "some status", program_id: 42, course_id: 42}
  @update_attrs %{title: "some updated title", description: "some updated description", status: "some updated status", program_id: 43, course_id: 43}
  @invalid_attrs %{title: nil, description: nil, status: nil, program_id: nil, course_id: nil}

  describe "index" do
    test "lists all program logs", %{conn: conn} do
      conn = get(conn, ~p"/log_program/laporan")
      assert html_response(conn, 200) =~ "Program Logs"
    end
  end

  describe "new program_log" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/log_program/laporan/new")
      assert html_response(conn, 200) =~ "Program Log Baharu"
    end
  end

  describe "create program_log" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/log_program/laporan", report: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/log_program/laporan/#{id}"

      conn = get(conn, ~p"/log_program/laporan/#{id}")
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/log_program/laporan", report: @invalid_attrs)
      assert html_response(conn, 200) =~ "Program Log Baharu"
    end
  end

  describe "edit program_log" do
    setup [:create_program_log]

    test "renders form for editing chosen program_log", %{conn: conn, program_log: program_log} do
      conn = get(conn, ~p"/log_program/laporan/#{program_log}/edit")
      assert html_response(conn, 200) =~ "Edit Program Log"
    end
  end

  describe "update program_log" do
    setup [:create_program_log]

    test "redirects when data is valid", %{conn: conn, program_log: program_log} do
      conn = put(conn, ~p"/log_program/laporan/#{program_log}", report: @update_attrs)
      assert redirected_to(conn) == ~p"/log_program/laporan/#{program_log}"

      conn = get(conn, ~p"/log_program/laporan/#{program_log}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, program_log: program_log} do
      conn = put(conn, ~p"/log_program/laporan/#{program_log}", report: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Program Log"
    end
  end

  describe "delete program_log" do
    setup [:create_program_log]

    test "deletes chosen program_log", %{conn: conn, program_log: program_log} do
      conn = delete(conn, ~p"/log_program/laporan/#{program_log}")
      assert redirected_to(conn) == ~p"/log_program/laporan"

      assert_error_sent 404, fn ->
        get(conn, ~p"/log_program/laporan/#{program_log}")
      end
    end
  end

  defp create_program_log(_) do
    program_log = program_log_fixture()
    %{program_log: program_log}
  end
end
