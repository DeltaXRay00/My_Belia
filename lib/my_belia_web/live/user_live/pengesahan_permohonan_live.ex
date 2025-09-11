defmodule MyBeliaWeb.UserLive.PengesahanPermohonanLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantFormState
  alias MyBelia.GrantApplications

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    session_id = "grant_form_#{user_id || "anon"}"
    form_data = GrantFormState.get_form_data(session_id) || %{}

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Pengesahan Permohonan",
       form_data: form_data,
       session_id: session_id,
       submission_errors: nil
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.pengesahan_permohonan(assigns)
  end

  def handle_event("submit-application", _params, socket) do
    session_id = socket.assigns.session_id
    current_user = socket.assigns.current_user
    form_data = GrantFormState.get_form_data(session_id) || %{}

    # Process staged documents and save them to permanent storage
    processed_documents = process_staged_documents(form_data["supporting_documents"] || %{})
    
    # Update form data with permanent file paths
    updated_form_data = Map.put(form_data, "supporting_documents", processed_documents)
    
    attrs = Map.put(updated_form_data, "user_id", current_user && current_user.id)

    case GrantApplications.create_grant_application(attrs) do
      {:ok, _grant_app} ->
        GrantFormState.delete_form_data(session_id)

        {:noreply,
         socket
         |> put_flash(:info, "Permohonan berjaya dihantar.")
         |> push_navigate(to: ~p"/permohonan_selesai")}

      {:error, changeset} ->
        {:noreply, assign(socket, submission_errors: changeset.errors)}
    end
  end

  # Helper function to process staged documents and move them to permanent storage
  defp process_staged_documents(documents) do
    Enum.map(documents, fn {doc_type, doc_data} ->
      case doc_data do
        # Handle single file
        %{"staged" => true} = file_data ->
          permanent_file = move_to_permanent_storage(file_data)
          {doc_type, permanent_file}
        
        # Handle multiple files (like sijil_pengiktirafan)
        files when is_list(files) ->
          permanent_files = Enum.map(files, fn file_data ->
            if file_data["staged"] do
              move_to_permanent_storage(file_data)
            else
              file_data  # Already permanent
            end
          end)
          {doc_type, permanent_files}
        
        # Already permanent file
        file_data ->
          {doc_type, file_data}
      end
    end)
    |> Enum.into(%{})
  end

  # Helper function to move staged file to permanent storage
  defp move_to_permanent_storage(file_data) do
    temp_path = file_data["temp_path"]
    original_name = file_data["original_name"]
    
    # Generate unique filename
    filename = "#{System.unique_integer([:positive])}_#{original_name}"
    dest = Path.join(["priv/static/uploads", filename])
    
    # Ensure directory exists
    File.mkdir_p!(Path.dirname(dest))
    
    # Move file to permanent location
    File.cp!(temp_path, dest)
    
    # Return permanent file data
    %{
      "filename" => filename,
      "original_name" => original_name,
      "path" => "/uploads/#{filename}",
      "size" => file_data["size"],
      "type" => file_data["type"]
    }
  end
end
