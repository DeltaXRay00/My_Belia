defmodule MyBeliaWeb.UserLive.DokumenSokonganGeranLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantFormState

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    session_id = "grant_form_#{user_id || "anon"}"
    form_data = GrantFormState.get_form_data(session_id) || %{}

    socket = 
      socket
      |> assign(
        current_user: current_user,
        page_title: "Dokumen Sokongan Geran",
        session_id: session_id,
        form_data: form_data,
        uploaded_documents: form_data["supporting_documents"] || %{}
      )
      |> allow_upload(:surat_sokongan, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:profil_organisasi, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:surat_kebenaran, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:rancangan_atur_cara, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:lesen_organisasi, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:sijil_pengiktirafan, accept: ~w(.pdf .jpg .jpeg .png), max_entries: 5, max_file_size: 10_000_000, auto_upload: false)
      |> allow_upload(:surat_rujukan, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan_geran(assigns)
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("trigger-upload", %{"upload" => upload}, socket) do
    upload_atom = String.to_existing_atom(upload)
    {:noreply, push_event(socket, "trigger-file-input", %{upload: upload})}
  end

  def handle_event("cancel-upload", %{"ref" => ref, "upload" => upload}, socket) do
    upload_atom = String.to_existing_atom(upload)
    {:noreply, cancel_upload(socket, upload_atom, ref)}
  end

  def handle_event("save-documents", _params, socket) do
    session_id = socket.assigns.session_id

    # Stage files (don't save to permanent storage yet)
    staged_documents = %{
      "surat_sokongan" => stage_upload(socket, :surat_sokongan),
      "profil_organisasi" => stage_upload(socket, :profil_organisasi),
      "surat_kebenaran" => stage_upload(socket, :surat_kebenaran),
      "rancangan_atur_cara" => stage_upload(socket, :rancangan_atur_cara),
      "lesen_organisasi" => stage_upload(socket, :lesen_organisasi),
      "sijil_pengiktirafan" => stage_upload(socket, :sijil_pengiktirafan),
      "surat_rujukan" => stage_upload(socket, :surat_rujukan)
    }

    # Merge with existing staged documents
    existing_documents = socket.assigns.uploaded_documents || %{}
    all_documents = Map.merge(existing_documents, staged_documents)

    # Update form data with staged file references
    existing_data = socket.assigns.form_data || %{}
    updated_data = Map.put(existing_data, "supporting_documents", all_documents)
    GrantFormState.store_form_data(session_id, updated_data)

    # Update socket with staged documents
    socket = assign(socket, uploaded_documents: all_documents)

    {:noreply, 
     socket
     |> put_flash(:info, "Dokumen telah dipilih dan akan disimpan selepas pengesahan!")
     |> push_navigate(to: ~p"/pengesahan_permohonan")}
  end

  def handle_event("remove-document", %{"document_type" => doc_type}, socket) do
    session_id = socket.assigns.session_id
    current_documents = socket.assigns.uploaded_documents || %{}
    
    # Remove document from the specific type
    updated_documents = Map.delete(current_documents, doc_type)

    # Update form data
    existing_data = socket.assigns.form_data || %{}
    updated_data = Map.put(existing_data, "supporting_documents", updated_documents)
    GrantFormState.store_form_data(session_id, updated_data)

    # Update socket
    socket = assign(socket, uploaded_documents: updated_documents)

    {:noreply, 
     socket
     |> put_flash(:info, "Dokumen berjaya dipadam!")}
  end

  # Helper function to stage uploads (store file info without moving to permanent storage)
  defp stage_upload(socket, upload_type) do
    consume_uploaded_entries(socket, upload_type, fn %{path: tmp_path}, entry ->
      # Store file info but don't move to permanent storage yet
      {:ok, %{
        "temp_path" => tmp_path,
        "original_name" => entry.client_name,
        "size" => entry.client_size,
        "type" => entry.client_type,
        "staged" => true
      }}
    end)
  end

  # Helper function to format file sizes
  def format_file_size(bytes) when is_integer(bytes) do
    cond do
      bytes < 1024 -> "#{bytes} B"
      bytes < 1024 * 1024 -> "#{Float.round(bytes / 1024, 1)} KB"
      bytes < 1024 * 1024 * 1024 -> "#{Float.round(bytes / (1024 * 1024), 1)} MB"
      true -> "#{Float.round(bytes / (1024 * 1024 * 1024), 1)} GB"
    end
  end

  def format_file_size(_), do: "0 B"
end
