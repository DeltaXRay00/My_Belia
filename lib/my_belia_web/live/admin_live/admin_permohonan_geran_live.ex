defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantApplications
  alias MyBelia.Documents

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    grant_applications = GrantApplications.list_grant_applications_with_details()

    {:ok,
     assign(socket,
       current_user: current_user,
       grant_applications: grant_applications,
       current_filter: "all",
       page_title: "Admin Permohonan Geran",
       selected_application: nil,
       show_view_modal: false,
       show_status_confirmation: false,
       status_change_application_id: nil,
       status_change_new_status: nil,
       status_change_current_status: nil,
       open_dropdown_id: nil,
       selected_grant_documents: []
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran(assigns)
  end

  # Review/update status via form submit (kept for parity with other pages)
  def handle_event("review-application", %{"application_id" => application_id, "status" => status, "notes" => notes}, socket) do
    current_user = socket.assigns.current_user

    case GrantApplications.update_application_status(application_id, status, current_user.id, notes) do
      {:ok, _application} ->
        grant_applications = refresh_by_filter(socket.assigns.current_filter)

        status_text = case status do
          "diluluskan" -> "Diluluskan"
          "ditolak" -> "Ditolak"
          "tidak_lengkap" -> "Tidak Lengkap"
          _ -> status
        end

        {:noreply,
         socket
         |> assign(grant_applications: grant_applications)
         |> put_flash(:info, "Permohonan telah #{status_text}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Ralat semasa mengemas kini status permohonan.")}
    end
  end

  def handle_event("filter-applications", %{"filter" => filter}, socket) do
    case filter do
      "all" ->
        grant_applications = GrantApplications.list_grant_applications_with_details()
        {:noreply, assign(socket, grant_applications: grant_applications, current_filter: "all")}

      status when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"] ->
        grant_applications = GrantApplications.list_grant_applications_by_status(status)
        {:noreply, assign(socket, grant_applications: grant_applications, current_filter: status)}

      _ ->
        {:noreply, socket}
    end
  end

  # Eye icon: show grant application details (from the grant form), preload user for display
  def handle_event("view-application", %{"application_id" => application_id}, socket) do
    try do
      application = GrantApplications.get_grant_application!(application_id)
      application = MyBelia.Repo.preload(application, [:user])
      grant_docs = Documents.list_grant_admin_documents(application.user_id)

      {:noreply,
       socket
       |> assign(:selected_application, application)
       |> assign(:selected_grant_documents, grant_docs)
       |> assign(:show_view_modal, true)}
    rescue
      e ->
        IO.inspect(e, label: "Error in view-application")
        {:noreply, put_flash(socket, :error, "Ralat semasa memuat maklumat pemohon.")}
    end
  end

  def handle_event("close-view-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_view_modal, false)
     |> assign(:selected_application, nil)
     |> assign(:selected_grant_documents, [])}
  end

  def handle_event("toggle-status-dropdown", %{"dropdown_id" => dropdown_id}, socket) do
    current_open = socket.assigns.open_dropdown_id

    if current_open == dropdown_id do
      {:noreply, assign(socket, :open_dropdown_id, nil)}
    else
      {:noreply, assign(socket, :open_dropdown_id, dropdown_id)}
    end
  end

  def handle_event("select-new-status", %{"application_id" => application_id, "new_status" => new_status}, socket) do
    current_application = Enum.find(socket.assigns.grant_applications, &(&1.id == application_id))
    current_status = if current_application, do: current_application.status, else: "menunggu"

    {:noreply,
     socket
     |> assign(:status_change_application_id, application_id)
     |> assign(:status_change_new_status, new_status)
     |> assign(:status_change_current_status, current_status)
     |> assign(:show_status_confirmation, true)}
  end

  def handle_event("confirm-status-change", _params, socket) do
    application_id = socket.assigns.status_change_application_id
    new_status = socket.assigns.status_change_new_status
    current_user = socket.assigns.current_user

    case GrantApplications.update_application_status(application_id, new_status, current_user.id, nil) do
      {:ok, _application} ->
        socket = socket
        |> assign(:show_status_confirmation, false)
        |> assign(:status_change_application_id, nil)
        |> assign(:status_change_new_status, nil)
        |> assign(:status_change_current_status, nil)
        |> assign(:open_dropdown_id, nil)

        grant_applications = refresh_by_filter(socket.assigns.current_filter)

        status_text = case new_status do
          "diluluskan" -> "Lulus"
          "ditolak" -> "Tolak"
          "tidak_lengkap" -> "Tidak Lengkap"
          "menunggu" -> "Menunggu"
          _ -> new_status
        end

        {:noreply,
         socket
         |> assign(:grant_applications, grant_applications)
         |> put_flash(:info, "Status permohonan telah berjaya diubah kepada #{status_text}.")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:show_status_confirmation, false)
         |> assign(:status_change_application_id, nil)
         |> assign(:status_change_new_status, nil)
         |> assign(:status_change_current_status, nil)
         |> put_flash(:error, "Ralat semasa mengemas kini status permohonan.")}
    end
  end

  def handle_event("cancel-status-change", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_status_confirmation, false)
     |> assign(:status_change_application_id, nil)
     |> assign(:status_change_new_status, nil)
     |> assign(:status_change_current_status, nil)}
  end

  def handle_event("delete-application", %{"application_id" => application_id}, socket) do
    application = GrantApplications.get_grant_application!(application_id)

    case GrantApplications.delete_grant_application(application) do
      {:ok, _} ->
        grant_applications = refresh_by_filter(socket.assigns.current_filter)
        {:noreply,
         socket
         |> assign(:grant_applications, grant_applications)
         |> put_flash(:info, "Permohonan berjaya dipadam")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Ralat semasa memadam permohonan.")}
    end
  end

  defp refresh_by_filter("all"), do: GrantApplications.list_grant_applications_with_details()
  defp refresh_by_filter(status) when status in ["menunggu", "diluluskan", "ditolak", "tidak_lengkap"],
    do: GrantApplications.list_grant_applications_by_status(status)
  defp refresh_by_filter(_), do: GrantApplications.list_grant_applications_with_details()

  # Kept from prior logic; currently unused but harmless
  defp rank_level(nil), do: 99
  defp rank_level(level) when is_binary(level) do
    case String.downcase(String.trim(level)) do
      "phd" -> 0
      "doktor falsafah" -> 0
      "sarjana" -> 1
      "master" -> 1
      "sarjana muda" -> 2
      "ijazah sarjana muda" -> 2
      "ijazah" -> 2
      "bachelor" -> 2
      "diploma" -> 3
      "stpm" -> 4
      "matrikulasi" -> 4
      "spm" -> 5
      _ -> 50
    end
  end
end
