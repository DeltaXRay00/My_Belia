defmodule MyBeliaWeb.AdminLive.LaporanProgramNewLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Reports
  alias MyBelia.Reports.Report

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)
    changeset = Reports.change_report(%Report{})

    {:ok,
     assign(socket,
       changeset: changeset,
       current_user: current_user,
       page_title: "Laporan Program Baharu"
     ), layout: false}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"report" => report_params}, socket) do
    case Reports.create_report(report_params) do
      {:ok, report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report created successfully.")
         |> push_navigate(to: ~p"/laporan_program/#{report}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    MyBeliaWeb.ReportHTML.new(assigns)
  end
end
