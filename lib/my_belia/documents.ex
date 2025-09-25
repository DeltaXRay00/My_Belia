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

  # Return ONLY general uploads from /dokumen_sokongan (exclude grant-step docs)
  # Allowed general doc types list can be extended as needed
  def list_general_user_documents(user_id) do
    allowed = [
      "ic",
      "birth",
      "father_ic",
      "mother_ic",
      "resume",
      "cover_letter",
      "support_letter",
      "education_cert",
      "activity_cert"
    ]

    UserDocument
    |> where(user_id: ^user_id)
    |> where([ud], ud.doc_type in ^allowed)
    |> Repo.all()
  end

  # Return ONLY grant-step uploads (those not part of general list)
  def list_grant_user_documents(user_id) do
    general = [
      "ic",
      "birth",
      "father_ic",
      "mother_ic",
      "resume",
      "cover_letter",
      "support_letter",
      "education_cert",
      "activity_cert"
    ]

    UserDocument
    |> where(user_id: ^user_id)
    |> where([ud], ud.doc_type not in ^general)
    |> Repo.all()
  end
  # Return ONLY the 6 specific grant documents for admin view
  def list_grant_admin_documents(user_id) do
    admin_grant_types = [
      "profil_organisasi",
      "rancangan_atur_cara",
      "sijil_pengiktirafan",
      "surat_kebenaran",
      "surat_sokongan",
      "surat_rujukan"
    ]

    UserDocument
    |> where(user_id: ^user_id)
    |> where([ud], ud.doc_type in ^admin_grant_types)
    |> Repo.all()
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
    user_id = Map.get(attrs, :user_id) || Map.get(attrs, "user_id")
    doc_type = Map.get(attrs, :doc_type) || Map.get(attrs, "doc_type")

    case get_user_document_by(user_id, doc_type) do
      nil ->
        create_user_document(attrs)
      %UserDocument{} = doc ->
        update_user_document(doc, attrs)
    end
  end

  def delete_user_document(%UserDocument{} = doc) do
    Repo.delete(doc)
  end
end
