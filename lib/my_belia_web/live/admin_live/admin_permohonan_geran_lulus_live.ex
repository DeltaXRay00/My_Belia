defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranLulusLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantApplications

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    # Get approved grant applications
    grant_applications = GrantApplications.list_grant_applications_by_status("diluluskan")

    {:ok,
     assign(socket,
       current_user: current_user,
       grant_applications: grant_applications,
       page_title: "Admin Permohonan Geran Lulus",
       current_filter: "diluluskan",
       selected_application: nil,
       user_documents: [],
       show_view_modal: false,
       show_status_confirmation: false,
       status_change_application_id: nil,
       status_change_new_status: nil,
       status_change_current_status: nil,
       open_dropdown_id: nil
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran_lulus(assigns)
  end

  def handle_event("view-application", %{"application_id" => application_id}, socket) do
    try do
      application = GrantApplications.get_grant_application!(application_id)
      application = MyBelia.Repo.preload(application, [:user])

      # Get user documents
      user_documents = MyBelia.Documents.get_user_documents(application.user_id)

      {:noreply,
       socket
       |> assign(:selected_application, application)
       |> assign(:user_documents, user_documents)
       |> assign(:show_view_modal, true)}
    rescue
      _e ->
        {:noreply, put_flash(socket, :error, "Ralat semasa memuat maklumat pemohon.")}
    end
  end

  def handle_event("close-view-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_view_modal, false)
     |> assign(:selected_application, nil)
     |> assign(:user_documents, [])}
  end

  def handle_event("delete-application", %{"application_id" => application_id}, socket) do
    application = GrantApplications.get_grant_application!(application_id)

    case GrantApplications.delete_grant_application(application) do
      {:ok, _} ->
        grant_applications = GrantApplications.list_grant_applications_by_status("diluluskan")

        {:noreply,
         socket
         |> assign(:grant_applications, grant_applications)
         |> put_flash(:info, "Permohonan berjaya dipadam")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Ralat semasa memadam permohonan.")}
    end
  end
end
