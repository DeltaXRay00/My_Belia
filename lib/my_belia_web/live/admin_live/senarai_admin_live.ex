defmodule MyBeliaWeb.AdminLive.SenaraiAdminLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Accounts

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: Accounts.get_user!(user_id)
    admins = Accounts.list_admin_users()

    {:ok,
     assign(socket,
       admins: admins,
       current_user: current_user,
       current_user_role: current_user.role,
       search: "",
       daerah: "",
       filtered_admins: nil,
       page_title: "Senarai Admin"
     ), layout: false}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user

    # Only superadmin can delete admin accounts
    if current_user.role == "superadmin" do
      admin = Accounts.get_user!(id)

      case Accounts.delete_user(admin) do
        {:ok, _user} ->
          admins = Accounts.list_admin_users()

          {:noreply,
           socket
           |> assign(admins: admins)
           |> put_flash(:info, "Admin berjaya dipadamkan.")}

        {:error, _changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Ralat semasa memadamkan admin.")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Anda tidak mempunyai kebenaran untuk memadamkan admin.")}
    end
  end

  def handle_event("filter", %{"search" => search, "daerah" => daerah}, socket) do
    admins = socket.assigns.admins

    filtered_admins =
      admins
      |> Enum.filter(fn admin ->
        search_matches =
          search == "" or
            String.contains?(String.downcase(admin.full_name || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.email || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.daerah || ""), String.downcase(search))

        daerah_matches =
          daerah == "" or
            String.downcase(admin.daerah || "") == String.downcase(daerah)

        search_matches and daerah_matches
      end)

    {:noreply, assign(socket, filtered_admins: filtered_admins, search: search, daerah: daerah)}
  end

  def handle_event("filter", %{"search" => search}, socket) do
    admins = socket.assigns.admins
    daerah = socket.assigns.daerah

    filtered_admins =
      admins
      |> Enum.filter(fn admin ->
        search_matches =
          search == "" or
            String.contains?(String.downcase(admin.full_name || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.email || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.daerah || ""), String.downcase(search))

        daerah_matches =
          daerah == "" or
            String.downcase(admin.daerah || "") == String.downcase(daerah)

        search_matches and daerah_matches
      end)

    {:noreply, assign(socket, filtered_admins: filtered_admins, search: search)}
  end

  def handle_event("filter", %{"daerah" => daerah}, socket) do
    admins = socket.assigns.admins
    search = socket.assigns.search

    filtered_admins =
      admins
      |> Enum.filter(fn admin ->
        search_matches =
          search == "" or
            String.contains?(String.downcase(admin.full_name || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.email || ""), String.downcase(search)) or
            String.contains?(String.downcase(admin.daerah || ""), String.downcase(search))

        daerah_matches =
          daerah == "" or
            String.downcase(admin.daerah || "") == String.downcase(daerah)

        search_matches and daerah_matches
      end)

    {:noreply, assign(socket, filtered_admins: filtered_admins, daerah: daerah)}
  end

  def handle_event("clear_filters", _params, socket) do
    {:noreply, assign(socket, filtered_admins: nil, search: "", daerah: "")}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_admin(assigns)
  end
end
