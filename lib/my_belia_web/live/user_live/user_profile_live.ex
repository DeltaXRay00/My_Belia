defmodule MyBeliaWeb.UserLive.UserProfileLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.Accounts

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

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

  def handle_event("save-profile", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, user_params) do
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
    case consume_and_store_avatar(socket) do
      {:ok, avatar_url} ->
        case Accounts.update_user(socket.assigns.current_user, %{avatar_url: avatar_url}) do
          {:ok, updated_user} ->
            {:noreply,
             socket
             |> assign(current_user: updated_user)
             |> put_flash(:info, "Avatar berjaya dikemaskini!")}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Ralat semasa menyimpan avatar.")}
        end

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Ralat semasa memuat naik avatar: #{reason}.")}
    end
  end

  def handle_event("validate-avatar", _params, socket) do
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
      [] -> {:error, "tiada fail"}
      other -> {:error, inspect(other)}
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
end
