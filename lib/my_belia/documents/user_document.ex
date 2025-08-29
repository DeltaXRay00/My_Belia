defmodule MyBelia.Documents.UserDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_documents" do
    field :doc_type, :string
    field :file_name, :string
    field :content_type, :string
    field :file_size, :integer
    field :file_url, :string

    belongs_to :user, MyBelia.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_document, attrs) do
    user_document
    |> cast(attrs, [:user_id, :doc_type, :file_name, :content_type, :file_size, :file_url])
    |> validate_required([:user_id, :doc_type, :file_name])
    |> validate_length(:doc_type, max: 50)
    |> unique_constraint([:user_id, :doc_type], name: :unique_user_doc_type)
  end
end
