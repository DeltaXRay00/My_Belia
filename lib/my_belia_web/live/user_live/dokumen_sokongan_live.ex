defmodule MyBeliaWeb.UserLive.DokumenSokonganLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.Documents

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    user_documents = if current_user, do: Documents.list_general_user_documents(current_user.id), else: []

    # Calculate progress
    uploaded_count = length(user_documents)
    upload_progress = round((uploaded_count / 9) * 100)

    socket = assign(socket,
      current_user: current_user,
      user_documents: user_documents,
      uploaded_count: uploaded_count,
      upload_progress: upload_progress,
      selected_files: %{}  # Track selected files
    )

    socket = socket
    |> allow_upload(:ic_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:birth_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:father_ic_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:mother_ic_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:resume_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:cover_letter_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:support_letter_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:education_cert_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)
    |> allow_upload(:activity_cert_file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000, auto_upload: false)

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.dokumen_sokongan(assigns)
  end

  def handle_event("upload-file", %{"file_key" => file_key, "filename" => filename, "content_type" => content_type, "file_data" => file_data}, socket) do
    # Handle file upload from JavaScript
    user = socket.assigns.current_user
    selected_files = socket.assigns.selected_files

    # Extract doc_type from file_key
    doc_type = case file_key do
      "ic_file" -> "ic"
      "birth_file" -> "birth"
      "father_ic_file" -> "father_ic"
      "mother_ic_file" -> "mother_ic"
      "resume_file" -> "resume"
      "cover_letter_file" -> "cover_letter"
      "support_letter_file" -> "support_letter"
      "education_cert_file" -> "education_cert"
      "activity_cert_file" -> "activity_cert"
    end

    # Create a temporary file from the base64 data
    case create_temp_file(file_data, filename) do
      {:ok, temp_path} ->
        # Create a Plug.Upload struct
        upload = %Plug.Upload{
          filename: filename,
          content_type: content_type,
          path: temp_path
        }

        # Process the file
        result = process_upload(upload, doc_type, user)

        case result do
          :ok ->
            # File was successfully processed and saved
            selected_files = Map.put(selected_files, file_key, %{
              filename: filename,
              status: :uploaded
            })

            # Get updated documents for progress
            user_documents = Documents.list_general_user_documents(user.id)
            uploaded_count = length(user_documents)
            upload_progress = round((uploaded_count / 9) * 100)

            {:noreply, assign(socket,
              selected_files: selected_files,
              user_documents: user_documents,
              uploaded_count: uploaded_count,
              upload_progress: upload_progress
            )}

          :error ->
            # File upload failed
            selected_files = Map.put(selected_files, file_key, %{
              filename: filename,
              status: :error
            })

            {:noreply, put_flash(assign(socket, selected_files: selected_files), :error, "Gagal memuat naik #{filename}")}
        end

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Gagal memproses fail #{filename}")}
    end
  end

  def handle_event("validate-documents", %{"_target" => [_file_key]} = _params, socket) do
    # Handle file selection feedback only (no processing here)
    {:noreply, socket}
  end

  def handle_event("validate-documents", _params, socket) do
    # Handle general validation (fallback)
    {:noreply, socket}
  end

  def handle_event("upload-file", _params, socket) do
    # Catch-all for upload-file events with different parameter structures
    {:noreply, socket}
  end



        def handle_event("save-all-documents", params, socket) do
    user = socket.assigns.current_user


    # Check if there's file data in the params
    case Map.get(params, "upload_file_data") do
      nil ->
        # No file data, just show status
        user_documents = Documents.list_general_user_documents(user.id)
        uploaded_count = length(user_documents)
        upload_progress = round((uploaded_count / 9) * 100)

        socket = assign(socket,
          user_documents: user_documents,
          uploaded_count: uploaded_count,
          upload_progress: upload_progress,
          selected_files: %{}
        )

        if uploaded_count > 0 do
          {:noreply, put_flash(socket, :info, "Status dokumen dikemas kini. #{uploaded_count} dokumen telah dimuat naik.")}
        else
          {:noreply, put_flash(socket, :info, "Tiada dokumen yang telah dimuat naik.")}
        end

      file_data_json ->
        # Process the file data
        case Jason.decode(file_data_json) do
          {:ok, file_data} ->

            # Extract file information
            file_key = file_data["file_key"]
            filename = file_data["filename"]
            content_type = file_data["content_type"]
            base64_data = file_data["file_data"]

            # Extract doc_type from file_key
            doc_type = case file_key do
              "ic_file" -> "ic"
              "birth_file" -> "birth"
              "father_ic_file" -> "father_ic"
              "mother_ic_file" -> "mother_ic"
              "resume_file" -> "resume"
              "cover_letter_file" -> "cover_letter"
              "support_letter_file" -> "support_letter"
              "education_cert_file" -> "education_cert"
              "activity_cert_file" -> "activity_cert"
            end

            # Create a temporary file from the base64 data
            case create_temp_file(base64_data, filename) do
              {:ok, temp_path} ->
                # Create a Plug.Upload struct
                upload = %Plug.Upload{
                  filename: filename,
                  content_type: content_type,
                  path: temp_path
                }

                # Process the file
                result = process_upload(upload, doc_type, user)

                case result do
                  :ok ->
                    # File was successfully processed and saved
                    user_documents = Documents.list_general_user_documents(user.id)
                    uploaded_count = length(user_documents)
                    upload_progress = round((uploaded_count / 9) * 100)

                    {:noreply, put_flash(assign(socket,
                      user_documents: user_documents,
                      uploaded_count: uploaded_count,
                      upload_progress: upload_progress,
                      selected_files: %{}
                    ), :info, "Berjaya memuat naik #{filename}")}

                  :error ->
                    {:noreply, put_flash(socket, :error, "Gagal memuat naik #{filename}")}
                end

              {:error, _reason} ->
                {:noreply, put_flash(socket, :error, "Gagal memproses fail #{filename}")}
            end

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Gagal memproses data fail")}
        end
    end
  end



  defp create_temp_file(base64_data, filename) do
    # Remove data URL prefix if present
    clean_data = case String.split(base64_data, ",", parts: 2) do
      [_prefix, data] -> data
      [data] -> data
    end

    # Decode base64 data
    case Base.decode64(clean_data) do
      {:ok, file_content} ->
        # Create temporary file
        temp_dir = Path.join(System.tmp_dir!(), "my_belia_uploads")
        File.mkdir_p!(temp_dir)

        temp_filename = "#{System.system_time()}_#{filename}"
        temp_path = Path.join(temp_dir, temp_filename)

        case File.write(temp_path, file_content) do
          :ok -> {:ok, temp_path}
          {:error, _reason} -> {:error, "Invalid base64 data"}
        end

      :error ->
        {:error, "Invalid base64 data"}
    end
  end

  defp process_upload(upload, doc_type, user) do
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
              # Save to database - use file_url instead of file_path
              document_params = %{
                user_id: user.id,
                doc_type: doc_type,
                file_name: upload.filename,
                file_url: "/uploads/documents/#{filename}",
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
  end


end
