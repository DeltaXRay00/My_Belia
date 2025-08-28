defmodule MyBelia.Documents do
  @moduledoc """
  Context for handling user support documents.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo

  alias MyBelia.Documents.UserDocument

  def list_user_documents(user_id) do
    UserDocument
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def get_user_documents(user_id) do
    UserDocument
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def get_user_document!(id), do: Repo.get!(UserDocument, id)

  def get_user_document_by(user_id, doc_type) do
    Repo.get_by(UserDocument, user_id: user_id, doc_type: doc_type)
  end

  def create_user_document(attrs) do
    %UserDocument{}
    |> UserDocument.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_document(%UserDocument{} = doc, attrs) do
    doc
    |> UserDocument.changeset(attrs)
    |> Repo.update()
  end

  def upsert_user_document(attrs) do
    IO.inspect("Upserting document with attrs: #{inspect(attrs)}", label: "UPSERT")

    case get_user_document_by(attrs.user_id, attrs.doc_type) do
      nil ->
        IO.inspect("No existing document found, creating new one", label: "UPSERT")
        create_user_document(attrs)
      %UserDocument{} = doc ->
        IO.inspect("Existing document found, updating: #{inspect(doc)}", label: "UPSERT")
        update_user_document(doc, attrs)
    end
  end

  def delete_user_document(%UserDocument{} = doc) do
    Repo.delete(doc)
  end
end
