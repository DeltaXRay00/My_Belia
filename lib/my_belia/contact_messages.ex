defmodule MyBelia.ContactMessages do
  @moduledoc """
  Context for storing contact form submissions.
  """

  import Ecto.Query
  import Ecto.Changeset
  alias MyBelia.Repo

  alias __MODULE__.ContactMessage

  defmodule ContactMessage do
    use Ecto.Schema

    schema "contact_messages" do
      field :name, :string
      field :email, :string
      field :contact_number, :string
      field :subject, :string
      field :message, :string

      field :admin_response, :string
      field :responded_at, :utc_datetime
      field :status, :string, default: "baru"
      belongs_to :responded_by, MyBelia.Accounts.User, foreign_key: :responded_by_id

      timestamps()
    end

    @doc false
    def changeset(struct, attrs) do
      struct
      |> cast(attrs, [:name, :email, :contact_number, :subject, :message, :admin_response, :status, :responded_by_id, :responded_at])
      |> validate_required([:name, :email, :subject, :message])
      |> validate_format(:email, ~r/^\S+@\S+\.[\S]+$/)
      |> validate_length(:message, min: 10)
    end
  end

  @spec create_contact_message(map) :: {:ok, ContactMessage.t()} | {:error, Ecto.Changeset.t()}
  def create_contact_message(attrs) do
    %ContactMessage{}
    |> ContactMessage.changeset(attrs)
    |> Repo.insert()
  end

  @spec change_contact_message(__MODULE__.ContactMessage.t(), map) :: Ecto.Changeset.t()
  def change_contact_message(%ContactMessage{} = contact_message, attrs \\ %{}) do
    ContactMessage.changeset(contact_message, attrs)
  end

  @spec get_contact_message!(integer) :: __MODULE__.ContactMessage.t()
  def get_contact_message!(id), do: Repo.get!(ContactMessage, id)

  @spec list_contact_messages() :: [__MODULE__.ContactMessage.t()]
  def list_contact_messages do
    Repo.all(ContactMessage)
  end

  @spec list_contact_messages(keyword) :: [__MODULE__.ContactMessage.t()]
  def list_contact_messages(opts) do
    status = Keyword.get(opts, :status, "semua")
    search = Keyword.get(opts, :search, "")

    query = ContactMessage
    |> order_by([c], desc: c.inserted_at)

    query = if status != "semua" do
      where(query, [c], c.status == ^status)
    else
      query
    end

    query = if search != "" do
      search_term = "%#{search}%"
      where(query, [c], ilike(c.name, ^search_term) or ilike(c.email, ^search_term) or ilike(c.subject, ^search_term))
    else
      query
    end

    Repo.all(query)
  end

  @spec list_contact_messages_by_status(String.t()) :: [__MODULE__.ContactMessage.t()]
  def list_contact_messages_by_status(status) do
    ContactMessage
    |> where([c], c.status == ^status)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @spec update_contact_message(__MODULE__.ContactMessage.t(), map) :: {:ok, __MODULE__.ContactMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_contact_message(%ContactMessage{} = contact_message, attrs) do
    contact_message
    |> ContactMessage.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_contact_message(__MODULE__.ContactMessage.t()) :: {:ok, __MODULE__.ContactMessage.t()}
  def delete_contact_message(%ContactMessage{} = contact_message) do
    Repo.delete(contact_message)
  end
end
