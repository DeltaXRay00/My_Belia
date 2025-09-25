defmodule MyBeliaWeb.PageLive.ContactLive do
  use MyBeliaWeb, :live_view

  alias MyBelia.ContactMessages
  alias MyBelia.ContactMessages.ContactMessage

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: MyBelia.Accounts.get_user!(user_id)

    changeset = ContactMessages.change_contact_message(%ContactMessage{}, %{subject: "general"})

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:changeset, changeset)
     |> assign(:submitted, false),
     layout: false}
  end

  @impl true
  def handle_event("validate", params, socket) do
    params = form_params(params)
    changeset =
      %ContactMessage{}
      |> ContactMessages.change_contact_message(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("submit", params, socket) do
    params = form_params(params)

    case ContactMessages.create_contact_message(params) do
      {:ok, _msg} ->
        {:noreply,
         socket
         |> put_flash(:info, "Terima kasih! Mesej anda telah dihantar.")
         |> assign(:submitted, true)
         |> assign(:changeset, ContactMessages.change_contact_message(%ContactMessage{}, %{subject: "general"}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  @impl true
  def render(assigns = %{current_user: %{role: "admin"}}) do
    ~H"""
    <.admin_layout page_title="Khidmat Pengguna">
      <%= MyBeliaWeb.PageHTML.contact(@assigns) %>
    </.admin_layout>
    """
  end

  def render(assigns) do
    MyBeliaWeb.PageHTML.contact(assigns)
  end

  # Accept both wrapped params (due to `as: :contact`) and partial updates during validate
  defp form_params(params) when is_map(params) do
    raw = Map.get(params, "contact", params)

    allowed = ["name", "email", "subject", "message", "contact_number"]

    raw
    |> Map.take(allowed)
    |> Map.put_new("subject", "general")
  end
end
