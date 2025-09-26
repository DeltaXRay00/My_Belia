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

  @spec change_contact_message(ContactMessage.t(), map) :: Ecto.Changeset.t()
  def change_contact_message(%ContactMessage{} = msg, attrs \\ %{}) do
    ContactMessage.changeset(msg, attrs)
  end

  @spec list_contact_messages(keyword) :: [ContactMessage.t()]
  def list_contact_messages(opts \\ []) do
    status = Keyword.get(opts, :status)
    search = Keyword.get(opts, :search)

    ContactMessage
    |> maybe_filter_status(status)
    |> maybe_search(search)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, "semua"), do: query
  defp maybe_filter_status(query, status) when is_binary(status), do: where(query, [m], m.status == ^status)

  defp maybe_search(query, nil), do: query
  defp maybe_search(query, ""), do: query
  defp maybe_search(query, term) do
    ilike_term = "%" <> term <> "%"
    where(query, [m], ilike(m.name, ^ilike_term) or ilike(m.email, ^ilike_term) or ilike(m.subject, ^ilike_term))
  end

  @spec get_contact_message!(integer) :: ContactMessage.t()
  def get_contact_message!(id), do: Repo.get!(ContactMessage, id)

  @spec update_contact_message(ContactMessage.t(), map) :: {:ok, ContactMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_contact_message(%ContactMessage{} = msg, attrs) do
    msg
    |> ContactMessage.changeset(attrs)
    |> Repo.update()
  end
end
