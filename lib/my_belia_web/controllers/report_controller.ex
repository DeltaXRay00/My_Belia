defmodule MyBeliaWeb.ReportController do
  use MyBeliaWeb, :controller

  alias MyBelia.Reports
  alias MyBelia.Reports.Report

  def index(conn, _params) do
    reports = Reports.list_reports()
    conn
    |> put_layout(false)
    |> render("index.html", reports: reports)
  end

  def new(conn, _params) do
    changeset = Reports.change_report(%Report{})
    conn
    |> put_layout(false)
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"report" => report_params}) do
    case Reports.create_report(report_params) do
      {:ok, report} ->
        conn
        |> put_flash(:info, "Report created successfully.")
        |> redirect(to: ~p"/laporan_program/#{report}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_layout(false)
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    report = Reports.get_report!(id)
    conn
    |> put_layout(false)
    |> render("show.html", report: report)
  end

  def edit(conn, %{"id" => id}) do
    report = Reports.get_report!(id)
    changeset = Reports.change_report(report)
    conn
    |> put_layout(false)
    |> render("edit.html", report: report, changeset: changeset)
  end

  def update(conn, %{"id" => id, "report" => report_params}) do
    report = Reports.get_report!(id)

    case Reports.update_report(report, report_params) do
      {:ok, report} ->
        conn
        |> put_flash(:info, "Report updated successfully.")
        |> redirect(to: ~p"/laporan_program/#{report}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_layout(false)
        |> render("edit.html", report: report, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    report = Reports.get_report!(id)
    {:ok, _report} = Reports.delete_report(report)

    conn
    |> put_flash(:info, "Report deleted successfully.")
    |> redirect(to: ~p"/laporan_program")
  end
end
