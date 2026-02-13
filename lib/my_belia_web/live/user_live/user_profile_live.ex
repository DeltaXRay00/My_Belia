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

      def handle_event("save-profile", %{"user" => user_params, "additional_education" => additional_education_params} = params, socket) do
    # Process avatar upload if any
    user_params_with_avatar = process_avatar_params(socket, user_params, params)

    # Start a transaction to handle both user update and education records
    Repo.transaction(fn ->
      # Update user profile
      case Accounts.update_user_profile(socket.assigns.current_user, user_params_with_avatar) do
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

  def handle_event("save-profile", %{"user" => user_params} = params, socket) do
    # Process avatar upload if any
    user_params_with_avatar = process_avatar_params(socket, user_params, params)

    case Accounts.update_user_profile(socket.assigns.current_user, user_params_with_avatar) do
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

  def handle_event("validate-profile", _params, socket) do
    # This will be called when the form changes, including avatar uploads

    # Check for avatar uploads
    {_entries, _errors} = uploaded_entries(socket, :avatar)

    {:noreply, socket}
  end

  def handle_event("avatar-upload", _params, socket) do
    {entries, _errors} = uploaded_entries(socket, :avatar)

    case entries do
      [] ->
        {:noreply, put_flash(socket, :error, "Tiada fail dipilih untuk dimuat naik.")}

      _ ->
        case consume_and_store_avatar(socket) do
          {:ok, avatar_url} ->
            case Accounts.update_user_profile(socket.assigns.current_user, %{avatar_url: avatar_url}) do
              {:ok, updated_user} ->
                user_with_educations = Accounts.get_user_with_educations!(updated_user.id)
                {:noreply,
                 socket
                 |> assign(current_user: user_with_educations)
                 |> put_flash(:info, "Avatar berjaya dimuat naik!")}

              {:error, _changeset} ->
                {:noreply, put_flash(socket, :error, "Ralat semasa menyimpan avatar.")}
            end

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Ralat semasa memproses fail.")}
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
      {:error, _reason} -> {:error, "Invalid base64 data"}
    end
  end

    defp process_avatar_params(socket, user_params, params) do
    # Check for different avatar upload scenarios
    cond do
      # Base64 data upload
      Map.get(params, "avatar_file_data") && Map.get(params, "avatar_file_data") != "" ->
        process_avatar_from_data(socket, user_params, Map.get(params, "avatar_file_data"))

      # File upload with flags
      Map.get(params, "avatar_uploaded") == "true" or Map.get(params, "trigger_avatar_upload") == "true" ->
        process_avatar_upload(socket, user_params)

      # Default: no avatar processing
      true ->
        user_params
    end
  end

  defp process_avatar_upload(socket, user_params) do
    # Check if there are any uploaded avatar files
    {entries, _errors} = uploaded_entries(socket, :avatar)

    case entries do
      [] ->
        # No avatar uploaded, preserve existing avatar_url
        if Map.has_key?(user_params, "avatar_url") do
          user_params
        else
          Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
        end

      _entries ->
        # Process the uploaded avatar
        case consume_and_store_avatar(socket) do
          {:ok, avatar_url} ->
            Map.put(user_params, "avatar_url", avatar_url)
          {:error, _reason} ->
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

    if avatar_file_data == "" do
      # No avatar data, preserve existing avatar_url
      if Map.has_key?(user_params, "avatar_url") do
        user_params
      else
        Map.put(user_params, "avatar_url", socket.assigns.current_user.avatar_url)
      end
    else
      # Process the avatar from base64 data
      case process_avatar_base64(socket.assigns.current_user.id, avatar_file_data) do
        {:ok, avatar_url} ->
          Map.put(user_params, "avatar_url", avatar_url)
        {:error, _reason} ->
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
          {:error, _reason} -> {:error, "Invalid base64 data"}
        end

      :error -> {:error, "Invalid base64 data"}
    end
  end
end
