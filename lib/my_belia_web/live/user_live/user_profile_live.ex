defmodule MyBeliaWeb.UserLive.UserProfileLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.Accounts
  alias MyBelia.Repo

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user_with_educations!(user_id)

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Profil Pengguna"
     )
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1, max_file_size: 5_000_000),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.user_profile(assigns)
  end

      def handle_event("save-profile", %{"user" => user_params, "additional_education" => additional_education_params, "avatar_uploaded" => avatar_uploaded, "trigger_avatar_upload" => trigger_avatar_upload, "avatar_file_data" => avatar_file_data}, socket) do
    IO.inspect("Save profile with education triggered", label: "SAVE PROFILE DEBUG")
    IO.inspect("User params: #{inspect(user_params)}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Avatar uploaded flag: #{avatar_uploaded}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Trigger avatar upload: #{trigger_avatar_upload}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Avatar file data present: #{avatar_file_data != ""}", label: "SAVE PROFILE DEBUG")

    # Process avatar upload if flag is set or trigger is set or file data is present
    user_params_with_avatar = if avatar_uploaded == "true" or trigger_avatar_upload == "true" or avatar_file_data != "" do
      IO.inspect("Processing avatar upload due to flag, trigger, or file data", label: "SAVE PROFILE DEBUG")
      process_avatar_from_data(socket, user_params, avatar_file_data)
    else
      user_params
    end

    # Start a transaction to handle both user update and education records
    Repo.transaction(fn ->
      # Update user profile
      case Accounts.update_user(socket.assigns.current_user, user_params_with_avatar) do
        {:ok, updated_user} ->
          # Delete existing education records
          Accounts.delete_user_educations(updated_user.id)

          # Create new education records
          Enum.each(additional_education_params, fn {_key, education_data} ->
            education_attrs = Map.put(education_data, "user_id", updated_user.id)
            Accounts.create_user_education(education_attrs)
          end)

          # Return updated user with education records
          Accounts.get_user_with_educations!(updated_user.id)

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
    |> case do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Profil dan avatar berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
    end
  end

      def handle_event("save-profile", %{"user" => user_params, "avatar_uploaded" => avatar_uploaded, "trigger_avatar_upload" => trigger_avatar_upload, "avatar_file_data" => avatar_file_data}, socket) do
    IO.inspect("Save profile triggered", label: "SAVE PROFILE DEBUG")
    IO.inspect("User params: #{inspect(user_params)}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Avatar uploaded flag: #{avatar_uploaded}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Trigger avatar upload: #{trigger_avatar_upload}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Avatar file data present: #{avatar_file_data != ""}", label: "SAVE PROFILE DEBUG")

    # Process avatar upload if flag is set or trigger is set or file data is present
    user_params_with_avatar = if avatar_uploaded == "true" or trigger_avatar_upload == "true" or avatar_file_data != "" do
      IO.inspect("Processing avatar upload due to flag, trigger, or file data", label: "SAVE PROFILE DEBUG")
      process_avatar_from_data(socket, user_params, avatar_file_data)
    else
      user_params
    end

    case Accounts.update_user(socket.assigns.current_user, user_params_with_avatar) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Profil dan avatar berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
        end
  end

  def handle_event("save-profile", %{"user" => user_params, "avatar_uploaded" => avatar_uploaded}, socket) do
    IO.inspect("Save profile triggered (no trigger field)", label: "SAVE PROFILE DEBUG")
    IO.inspect("User params: #{inspect(user_params)}", label: "SAVE PROFILE DEBUG")
    IO.inspect("Avatar uploaded flag: #{avatar_uploaded}", label: "SAVE PROFILE DEBUG")

    # Process avatar upload if flag is set
    user_params_with_avatar = if avatar_uploaded == "true" do
      IO.inspect("Processing avatar upload due to flag", label: "SAVE PROFILE DEBUG")
      process_avatar_upload(socket, user_params)
    else
      user_params
    end

    case Accounts.update_user(socket.assigns.current_user, user_params_with_avatar) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Profil dan avatar berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
    end
  end

  def handle_event("save-profile", %{"user" => user_params}, socket) do
    IO.inspect("Save profile triggered (no avatar fields)", label: "SAVE PROFILE DEBUG")
    IO.inspect("User params: #{inspect(user_params)}", label: "SAVE PROFILE DEBUG")
    # Process avatar upload if any
    user_params_with_avatar = process_avatar_upload(socket, user_params)

    case Accounts.update_user(socket.assigns.current_user, user_params_with_avatar) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Profil dan avatar berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
    end
  end

  def handle_event("validate-profile", params, socket) do
    # This will be called when the form changes, including avatar uploads
    IO.inspect("Validate profile triggered", label: "VALIDATE PROFILE DEBUG")
    IO.inspect("Validate params: #{inspect(params)}", label: "VALIDATE PROFILE DEBUG")

    # Check for avatar uploads
    {entries, errors} = uploaded_entries(socket, :avatar)
    IO.inspect("Validate - avatar entries: #{length(entries)}, errors: #{length(errors)}", label: "VALIDATE PROFILE DEBUG")

    {:noreply, socket}
  end

  def handle_event("avatar-upload", _params, socket) do
    IO.inspect("Avatar upload event triggered", label: "AVATAR UPLOAD DEBUG")
    {entries, errors} = uploaded_entries(socket, :avatar)
    IO.inspect("Avatar upload - entries: #{length(entries)}, errors: #{length(errors)}", label: "AVATAR UPLOAD DEBUG")

    case entries do
      [] ->
        {:noreply, put_flash(socket, :error, "Tiada fail dipilih untuk dimuat naik.")}

      _ ->
        case consume_and_store_avatar(socket) do
          {:ok, avatar_url} ->
            IO.inspect("Avatar stored successfully: #{avatar_url}", label: "AVATAR UPLOAD DEBUG")
            case Accounts.update_user(socket.assigns.current_user, %{avatar_url: avatar_url}) do
              {:ok, updated_user} ->
                user_with_educations = Accounts.get_user_with_educations!(updated_user.id)
                {:noreply,
                 socket
                 |> assign(current_user: user_with_educations)
                 |> put_flash(:info, "Avatar berjaya dimuat naik!")}

              {:error, changeset} ->
                IO.inspect("Error updating user: #{inspect(changeset.errors)}", label: "AVATAR UPLOAD DEBUG")
                {:noreply, put_flash(socket, :error, "Ralat semasa menyimpan avatar.")}
            end

          {:error, reason} ->
            IO.inspect("Error storing avatar: #{reason}", label: "AVATAR UPLOAD DEBUG")
            {:noreply, put_flash(socket, :error, "Ralat semasa memproses fail: #{reason}")}
        end
    end
  end



  defp consume_and_store_avatar(socket) do
    uploaded =
      consume_uploaded_entries(socket, :avatar, fn meta, entry ->
        with {:ok, url} <- persist_avatar(socket.assigns.current_user.id, meta.path, entry.client_name) do
          {:ok, url}
        else
          {:error, reason} -> {:postpone, reason}
        end
      end)

    case uploaded do
      [url | _] when is_binary(url) -> {:ok, url}
      [] -> {:error, "tiada fail dipilih"}
      other -> {:error, "ralat semasa memproses fail: #{inspect(other)}"}
    end
  end

  defp persist_avatar(user_id, tmp_path, client_name) do
    uploads_dir = Path.join([:code.priv_dir(:my_belia), "static", "uploads", "avatars"])
    :ok = File.mkdir_p(uploads_dir)

    ext = Path.extname(client_name)
    filename = "#{user_id}_#{System.system_time()}#{ext}"
    dest = Path.join(uploads_dir, filename)

    case File.cp(tmp_path, dest) do
      :ok -> {:ok, "/uploads/avatars/#{filename}"}
      {:error, reason} -> {:error, reason}
    end
  end

    defp process_avatar_upload(socket, user_params) do
    # Check if there are any uploaded avatar files
    {entries, errors} = uploaded_entries(socket, :avatar)
    IO.inspect("Avatar upload check - entries: #{length(entries)}, errors: #{length(errors)}", label: "AVATAR DEBUG")
    IO.inspect("Current user avatar_url: #{socket.assigns.current_user.avatar_url}", label: "AVATAR DEBUG")

    case entries do
      [] ->
        IO.inspect("No avatar entries found, preserving existing avatar", label: "AVATAR DEBUG")
        # No avatar uploaded, preserve existing avatar_url
        if Map.has_key?(user_params, "avatar_url") do
          user_params
        else
          Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
        end

      _entries ->
        IO.inspect("Found avatar entries, processing upload", label: "AVATAR DEBUG")
        # Process the uploaded avatar
        case consume_and_store_avatar(socket) do
          {:ok, avatar_url} ->
            IO.inspect("Avatar processed successfully: #{avatar_url}", label: "AVATAR DEBUG")
            Map.put(user_params, "avatar_url", avatar_url)
          {:error, reason} ->
            IO.inspect("Avatar processing failed: #{reason}", label: "AVATAR DEBUG")
            # If avatar processing fails, preserve existing avatar_url
            if Map.has_key?(user_params, "avatar_url") do
              user_params
            else
              Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
            end
        end
    end
  end

  defp process_avatar_from_data(socket, user_params, avatar_file_data) do
    IO.inspect("Processing avatar from file data", label: "AVATAR DEBUG")

    if avatar_file_data == "" do
      IO.inspect("No avatar file data provided", label: "AVATAR DEBUG")
      # No avatar data, preserve existing avatar_url
      if Map.has_key?(user_params, "avatar_url") do
        user_params
      else
        Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
      end
    else
      IO.inspect("Avatar file data provided, processing", label: "AVATAR DEBUG")
      # Process the avatar from base64 data
      case process_avatar_base64(socket.assigns.current_user.id, avatar_file_data) do
        {:ok, avatar_url} ->
          IO.inspect("Avatar processed successfully from base64: #{avatar_url}", label: "AVATAR DEBUG")
          Map.put(user_params, "avatar_url", avatar_url)
        {:error, reason} ->
          IO.inspect("Avatar processing failed from base64: #{reason}", label: "AVATAR DEBUG")
          # If avatar processing fails, preserve existing avatar_url
          if Map.has_key?(user_params, "avatar_url") do
            user_params
          else
            Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
          end
      end
    end
  end

  defp process_avatar_base64(user_id, base64_data) do
    # Extract the base64 data (remove data:image/jpeg;base64, prefix)
    clean_data = case String.split(base64_data, ",", parts: 2) do
      [_prefix, data] -> data
      [data] -> data
    end

    case Base.decode64(clean_data) do
      {:ok, file_content} ->
        # Determine file extension from the data URL
        ext = case String.split(base64_data, ";", parts: 2) do
          ["data:image/jpeg", _] -> ".jpg"
          ["data:image/png", _] -> ".png"
          ["data:image/gif", _] -> ".gif"
          _ -> ".jpg"  # Default to jpg
        end

        # Save the file
        uploads_dir = Path.join([:code.priv_dir(:my_belia), "static", "uploads", "avatars"])
        :ok = File.mkdir_p(uploads_dir)

        filename = "#{user_id}_#{System.system_time()}#{ext}"
        dest = Path.join(uploads_dir, filename)

        case File.write(dest, file_content) do
          :ok -> {:ok, "/uploads/avatars/#{filename}"}
          {:error, reason} -> {:error, reason}
        end

      :error -> {:error, "Invalid base64 data"}
    end
  end
end
