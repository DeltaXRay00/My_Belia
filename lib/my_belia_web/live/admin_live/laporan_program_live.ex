defmodule MyBeliaWeb.AdminLive.LaporanProgramLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Reports

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    reports = Reports.list_reports()
    {:ok, assign(socket, reports: reports, current_user: current_user, page_title: "Laporan Program"), layout: false}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    report = Reports.get_report!(id)
    {:noreply, assign(socket, report: report)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    report = Reports.get_report!(id)
    {:ok, _} = Reports.delete_report(report)

    {:noreply,
     socket
     |> put_flash(:info, "Report deleted successfully.")
     |> push_navigate(to: ~p"/laporan_program")}
  end

  def render(assigns) do
    MyBeliaWeb.ReportHTML.index(assigns)
  end
end
