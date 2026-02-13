defmodule MyBeliaWeb.AdminLive.AdminSenaraiGeranLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.Grants

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    grants = Grants.list_grants()

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Senarai Geran",
       grants: grants,
       pagination: %{entries: grants, page_number: 1, page_size: length(grants), total_entries: length(grants), total_pages: 1}
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.senarai_geran(assigns)
  end
end
