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

  def handle_event("save-profile", %{"user" => user_params, "additional_education" => additional_education_params}, socket) do
    # Process avatar upload if any
    user_params_with_avatar = process_avatar_upload(socket, user_params)

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
         |> put_flash(:info, "Profil berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
    end
  end

  def handle_event("save-profile", %{"user" => user_params}, socket) do
    # Process avatar upload if any
    user_params_with_avatar = process_avatar_upload(socket, user_params)

    case Accounts.update_user(socket.assigns.current_user, user_params_with_avatar) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(current_user: updated_user)
         |> put_flash(:info, "Profil berjaya dikemaskini!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa mengemaskini profil.")}
    end
  end

  def handle_event("save-avatar", _params, socket) do
    IO.inspect("save-avatar event triggered", label: "DEBUG")

    # Check if there are any uploaded files first
    {entries, errors} = uploaded_entries(socket, :avatar)
    IO.inspect("Avatar entries: #{length(entries)}, errors: #{length(errors)}", label: "DEBUG")

    case entries do
      [] ->
        IO.inspect("No avatar entries found", label: "DEBUG")
        {:noreply, put_flash(socket, :error, "Tiada fail dipilih untuk dimuat naik.")}

      _ ->
        IO.inspect("Processing avatar upload", label: "DEBUG")
        case consume_and_store_avatar(socket) do
          {:ok, avatar_url} ->
            IO.inspect("Avatar stored successfully: #{avatar_url}", label: "DEBUG")
            case Accounts.update_user(socket.assigns.current_user, %{avatar_url: avatar_url}) do
              {:ok, updated_user} ->
                # Get the updated user with education records
                user_with_educations = Accounts.get_user_with_educations!(updated_user.id)
                {:noreply,
                 socket
                 |> assign(current_user: user_with_educations)
                 |> put_flash(:info, "Avatar berjaya dimuat naik!")}

              {:error, changeset} ->
                IO.inspect("Error updating user: #{inspect(changeset.errors)}", label: "DEBUG")
                {:noreply, put_flash(socket, :error, "Ralat semasa menyimpan avatar.")}
            end

          {:error, reason} ->
            IO.inspect("Error storing avatar: #{reason}", label: "DEBUG")
            {:noreply, put_flash(socket, :error, "Ralat semasa memproses fail: #{reason}")}
        end
    end
  end

  def handle_event("validate-avatar", _params, socket) do
    IO.inspect("validate-avatar event triggered", label: "DEBUG")
    {entries, errors} = uploaded_entries(socket, :avatar)
    IO.inspect("Validate avatar - entries: #{length(entries)}, errors: #{length(errors)}", label: "DEBUG")
    {:noreply, socket}
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
end
