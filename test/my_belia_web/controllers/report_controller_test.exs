defmodule MyBeliaWeb.ReportControllerTest do
  use MyBeliaWeb.ConnCase

  import MyBelia.ReportsFixtures

  @create_attrs %{"title" => "some title", "content" => "some content"}
  @update_attrs %{"title" => "some updated title", "content" => "some updated content"}
  @invalid_attrs %{"title" => nil, "content" => nil}

  describe "index" do
    test "lists all reports", %{conn: conn} do
      conn = get(conn, ~p"/log_program/laporan")
      assert html_response(conn, 200) =~ "Log Program"
    end
  end

  describe "new report" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/log_program/laporan/new")
      assert html_response(conn, 200) =~ "New Report"
    end
  end

  describe "create report" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/log_program/laporan", report: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/log_program/laporan/#{id}"

      conn = get(conn, ~p"/log_program/laporan/#{id}")
      assert html_response(conn, 200) =~ "some title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/log_program/laporan", report: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Report"
    end
  end

  describe "edit report" do
    setup [:create_report]

    test "renders form for editing chosen report", %{conn: conn, report: report} do
      conn = get(conn, ~p"/log_program/laporan/#{report}/edit")
      assert html_response(conn, 200) =~ "Edit Report"
    end
  end

  describe "update report" do
    setup [:create_report]

    test "redirects when data is valid", %{conn: conn, report: report} do
      conn = put(conn, ~p"/log_program/laporan/#{report}", report: @update_attrs)
      assert redirected_to(conn) == ~p"/log_program/laporan/#{report}"

      conn = get(conn, ~p"/log_program/laporan/#{report}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, report: report} do
      conn = put(conn, ~p"/log_program/laporan/#{report}", report: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Report"
    end
  end

  describe "delete report" do
    setup [:create_report]

    test "deletes chosen report", %{conn: conn, report: report} do
      conn = delete(conn, ~p"/log_program/laporan/#{report}")
      assert redirected_to(conn) == ~p"/log_program/laporan"

      assert_error_sent 404, fn ->
        get(conn, ~p"/log_program/laporan/#{report}")
      end
    end
  end

  defp create_report(_) do
    report = report_fixture()
    %{report: report}
  end
end
