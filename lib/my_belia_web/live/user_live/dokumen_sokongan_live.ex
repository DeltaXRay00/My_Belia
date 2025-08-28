defmodule MyBeliaWeb.UserLive.DokumenSokonganLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.Documents

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    user_documents = if current_user, do: Documents.get_user_documents(current_user.id), else: []

    # Calculate progress
    uploaded_count = length(user_documents)
    upload_progress = round((uploaded_count / 9) * 100)

    socket = assign(socket,
      current_user: current_user,
      user_documents: user_documents,
      uploaded_count: uploaded_count,
      upload_progress: upload_progress
    )

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan(assigns)
  end

  def handle_event("validate-documents", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save-all-documents", params, socket) do
    user = socket.assigns.current_user

    # Process each file upload
    results = [
      process_file_upload(params, "ic_file", "ic", user),
      process_file_upload(params, "birth_file", "birth", user),
      process_file_upload(params, "father_ic_file", "father_ic", user),
      process_file_upload(params, "mother_ic_file", "mother_ic", user),
      process_file_upload(params, "resume_file", "resume", user),
      process_file_upload(params, "cover_letter_file", "cover_letter", user),
      process_file_upload(params, "support_letter_file", "support_letter", user),
      process_file_upload(params, "education_cert_file", "education_cert", user),
      process_file_upload(params, "activity_cert_file", "activity_cert", user)
    ]

    # Count successful uploads
    successful_uploads = Enum.count(results, &(&1 == :ok))

    # Get updated documents
    user_documents = Documents.get_user_documents(user.id)
    uploaded_count = length(user_documents)
    upload_progress = round((uploaded_count / 9) * 100)

    socket = assign(socket,
      user_documents: user_documents,
      uploaded_count: uploaded_count,
      upload_progress: upload_progress
    )

    if successful_uploads > 0 do
      {:noreply, put_flash(socket, :info, "Berjaya menyimpan #{successful_uploads} dokumen!")}
    else
      {:noreply, put_flash(socket, :error, "Tiada fail yang dipilih untuk dimuat naik.")}
    end
  end

  defp process_file_upload(params, file_key, doc_type, user) do
    case Map.get(params, file_key) do
      %Plug.Upload{} = upload ->
        # Get file size using File.stat
        case File.stat(upload.path) do
          {:ok, %File.Stat{size: size}} ->
            # Validate file
            if upload.content_type == "application/pdf" and size <= 10_000_000 do
              # Save file to disk
              upload_dir = Path.join(["priv", "static", "uploads", "documents"])
              File.mkdir_p!(upload_dir)

              filename = "#{user.id}_#{doc_type}_#{upload.filename}"
              file_path = Path.join(upload_dir, filename)

              case File.cp(upload.path, file_path) do
                :ok ->
                  # Save to database
                  document_params = %{
                    user_id: user.id,
                    doc_type: doc_type,
                    file_name: upload.filename,
                    file_path: "/uploads/documents/#{filename}",
                    file_size: size,
                    content_type: upload.content_type
                  }

                  case Documents.upsert_user_document(document_params) do
                    {:ok, _document} -> :ok
                    {:error, _changeset} -> :error
                  end

                {:error, _reason} -> :error
              end
            else
              :error
            end

          {:error, _reason} -> :error
        end

      _ -> :no_file
    end
  end
end
