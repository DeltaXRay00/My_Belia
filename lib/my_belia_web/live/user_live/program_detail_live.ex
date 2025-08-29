defmodule MyBeliaWeb.UserLive.ProgramDetailLive do
  use MyBeliaWeb, :live_view
  alias MyBelia.ProgramApplications
  alias MyBelia.Documents

  def mount(%{"id" => id}, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user_with_educations!(user_id)
    program = MyBelia.Programs.get_program!(id)

    # Check if user has already applied for this program
    has_applied = if current_user do
      ProgramApplications.user_has_applied_for_program?(current_user.id, program.id)
    else
      false
    end

    # Get user's documents and education if user exists
    user_documents = if current_user do
      Documents.get_user_documents(current_user.id)
    else
      []
    end

    user_educations = if current_user do
      current_user.user_educations
    else
      []
    end

    # Check if user meets application requirements
    can_apply = if current_user do
      has_required_documents = length(user_documents) > 0
      has_education = length(user_educations) > 0
      not has_applied and has_required_documents and has_education
    else
      false
    end

    {:ok,
     assign(socket,
       current_user: current_user,
       program: program,
       has_applied: has_applied,
       can_apply: can_apply,
       user_documents: user_documents,
       user_educations: user_educations,
       page_title: program.name
     ),
     layout: false}
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.program_detail(assigns)
  end

  def handle_event("apply-for-program", _params, socket) do
    user = socket.assigns.current_user
    program = socket.assigns.program

    if socket.assigns.can_apply do
      # Get user's latest document and education
      user_documents = socket.assigns.user_documents
      user_educations = socket.assigns.user_educations

      latest_document = List.first(user_documents)
      latest_education = List.first(user_educations)

      application_attrs = %{
        user_id: user.id,
        program_id: program.id,
        user_documents_id: if(latest_document, do: latest_document.id),
        user_education_id: if(latest_education, do: latest_education.id),
        application_date: Date.utc_today(),
        status: "menunggu"
      }

      case ProgramApplications.create_program_application(application_attrs) do
        {:ok, _application} ->
          {:noreply,
           socket
           |> assign(has_applied: true, can_apply: false)
           |> put_flash(:info, "Permohonan anda untuk program '#{program.name}' telah berjaya dihantar!")}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Ralat semasa menghantar permohonan. Sila cuba lagi.")}
      end
    else
      {:noreply, put_flash(socket, :error, "Anda tidak layak untuk memohon program ini.")}
    end
  end
end
