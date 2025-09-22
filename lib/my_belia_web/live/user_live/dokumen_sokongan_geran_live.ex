defmodule MyBeliaWeb.UserLive.DokumenSokonganGeranLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Documents

  @grant_doc_types [
    "surat_sokongan",
    "profil_organisasi",
    "surat_kebenaran",
    "rancangan_atur_cara",
    "lesen_organisasi",
    "sijil_pengiktirafan",
    "surat_rujukan"
  ]

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    uploaded_documents = load_uploaded_documents(current_user)

    socket = assign(socket,
      current_user: current_user,
      uploaded_documents: uploaded_documents
    )

    socket =
      socket
      |> allow_upload(:surat_sokongan, accept: ~w(.pdf), max_entries: 1, auto_upload: false)
      |> allow_upload(:profil_organisasi, accept: ~w(.pdf), max_entries: 1, auto_upload: false)
      |> allow_upload(:surat_kebenaran, accept: ~w(.pdf), max_entries: 1, auto_upload: false)
      |> allow_upload(:rancangan_atur_cara, accept: ~w(.pdf), max_entries: 1, auto_upload: false)
      |> allow_upload(:lesen_organisasi, accept: ~w(.pdf), max_entries: 1, auto_upload: false)
      |> allow_upload(:sijil_pengiktirafan, accept: ~w(.pdf .jpg .jpeg .png), max_entries: 5, auto_upload: false)
      |> allow_upload(:surat_rujukan, accept: ~w(.pdf), max_entries: 1, auto_upload: false)

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan_geran(assigns)
  end

  # Client event handlers
  def handle_event("trigger-upload", %{"upload" => upload}, socket) do
    {:noreply, push_event(socket, "phx:trigger-file-input", %{upload: upload})}
  end

  def handle_event("cancel-upload", %{"ref" => ref, "upload" => upload}, socket) do
    {:noreply, cancel_upload(socket, String.to_atom(upload), ref)}
  end

  def handle_event("remove-document", %{"document_type" => doc_type}, socket) do
    user = socket.assigns.current_user
    if user do
      if doc = Documents.get_user_document_by(user.id, doc_type) do
        Documents.delete_user_document(doc)
      end
    end

    {:noreply, assign(socket, uploaded_documents: load_uploaded_documents(user))}
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  # Submit (Next)
  def handle_event("save-documents", _params, socket) do
    user = socket.assigns.current_user
    socket = persist_all_uploads(socket, user)
    {:noreply, push_navigate(socket, to: ~p"/pengesahan_permohonan")}
  end

  # Back: persist then navigate back to skim geran
  def handle_event("save-and-back", _params, socket) do
    user = socket.assigns.current_user
    socket = persist_all_uploads(socket, user)
    {:noreply, push_navigate(socket, to: ~p"/skim_geran")}
  end

  # Helpers
  defp persist_all_uploads(socket, nil), do: socket
  defp persist_all_uploads(socket, user) do
    Enum.reduce(@grant_doc_types, socket, fn key, sock ->
      upload_key = String.to_atom(key)
      consume_uploaded_entries(sock, upload_key, fn %{path: path}, entry ->
        save_upload(user, key, entry.client_type, entry.client_name, path)
        :ok
      end)
      sock
    end)
    |> assign(:uploaded_documents, load_uploaded_documents(user))
  end

  defp save_upload(nil, _key, _ctype, _name, _path), do: :noop
  defp save_upload(user, doc_type, content_type, filename, temp_path) do
    upload_dir = Path.join(["priv", "static", "uploads", "documents"])
    File.mkdir_p!(upload_dir)

    stored_name = "#{user.id}_#{doc_type}_#{filename}"
    dest = Path.join(upload_dir, stored_name)
    File.cp!(temp_path, dest)

    {:ok, file_bytes} = File.read(dest)

    attrs = %{
      user_id: user.id,
      doc_type: doc_type,
      file_name: filename,
      file_url: "/uploads/documents/#{stored_name}",
      content_type: content_type,
      file_size: File.stat!(dest).size,
      file_blob: file_bytes
    }

    Documents.upsert_user_document(attrs)
  end

  defp load_uploaded_documents(nil), do: %{}
  defp load_uploaded_documents(user) do
    docs = Documents.list_grant_user_documents(user.id)

    Enum.reduce(docs, %{}, fn d, acc ->
      case d.doc_type do
        "sijil_pengiktirafan" ->
          Map.update(acc, "sijil_pengiktirafan", [%{"original_name" => d.file_name, "url" => d.file_url}], fn list ->
            [%{"original_name" => d.file_name, "url" => d.file_url} | list]
          end)
        other ->
          Map.put(acc, other, %{"original_name" => d.file_name, "url" => d.file_url})
      end
    end)
  end
end
