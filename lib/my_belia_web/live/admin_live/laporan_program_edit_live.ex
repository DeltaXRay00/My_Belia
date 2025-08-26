defmodule MyBeliaWeb.AdminLive.LaporanProgramEditLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Reports

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    {:ok, assign(socket, current_user: current_user, page_title: "Kemaskini Laporan Program"),
     layout: false}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    report = Reports.get_report!(id)
    changeset = Reports.change_report(report)
    {:noreply, assign(socket, report: report, changeset: changeset)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"report" => report_params}, socket) do
    report = socket.assigns.report

    case Reports.update_report(report, report_params) do
      {:ok, report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report updated successfully.")
         |> push_navigate(to: ~p"/laporan_program/#{report}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    MyBeliaWeb.ReportHTML.edit(assigns)
  end
end
