defmodule MyBeliaWeb.AdminLive.AdminPermohonanGeranTolakLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantApplications

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    grant_applications = GrantApplications.list_grant_applications_by_status("ditolak")

    {:ok,
     assign(socket,
       current_user: current_user,
       grant_applications: grant_applications,
       page_title: "Admin Permohonan Geran Tolak"
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.admin_permohonan_geran_tolak(assigns)
  end
end
