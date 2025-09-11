defmodule MyBeliaWeb.UserLive.SkimGeranLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.GrantFormState

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    # Use a stable session id so later steps can reuse the same data
    session_id = "grant_form_#{user_id || "anon"}"
    form_data = GrantFormState.get_form_data(session_id) || %{}

    {:ok,
     assign(socket,
       current_user: current_user,
       page_title: "Skim Geran",
       form_data: form_data,
       session_id: session_id
     ), layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.skim_geran(assigns)
  end

  def handle_event("save-form-data", params, socket) do
    session_id = socket.assigns.session_id
    existing_data = socket.assigns.form_data || %{}

    new_data = %{
      "grant_scheme" => params["grant_scheme"] || "",
      "grant_amount" => params["grant_amount"] || "",
      "project_duration" => params["project_duration"] || "",
      "project_name" => params["project_name"] || "",
      "project_objective" => params["project_objective"] || "",
      "target_group" => params["target_group"] || "",
      "project_location" => params["project_location"] || "",
      "project_start_date" => params["project_start_date"] || "",
      "project_end_date" => params["project_end_date"] || "",
      "equipment_cost" => params["equipment_cost"] || "",
      "material_cost" => params["material_cost"] || "",
      "transport_cost" => params["transport_cost"] || "",
      "admin_cost" => params["admin_cost"] || "",
      "other_cost" => params["other_cost"] || "",
      "total_budget" => params["total_budget"] || ""
    }

    updated_form_data = Map.merge(existing_data, new_data)
    GrantFormState.store_form_data(session_id, updated_form_data)

    {:noreply, push_navigate(socket, to: ~p"/dokumen_sokongan_geran")}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
