defmodule MyBelia.ProgramApplications.ProgramApplication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "program_applications" do
    field :application_date, :date
    field :status, :string, default: "menunggu"
    field :review_date, :date
    field :review_notes, :string

    belongs_to :user, MyBelia.Accounts.User
    belongs_to :program, MyBelia.Program
    belongs_to :user_documents, MyBelia.Documents.UserDocument
    belongs_to :user_education, MyBelia.Accounts.UserEducation
    belongs_to :reviewed_by, MyBelia.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(program_application, attrs) do
    program_application
    |> cast(attrs, [:user_id, :program_id, :user_documents_id, :user_education_id, :application_date, :status, :reviewed_by_id, :review_date, :review_notes])
    |> validate_required([:user_id, :program_id, :application_date, :status])
    |> validate_inclusion(:status, ["menunggu", "diluluskan", "ditolak", "tidak lengkap"])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:program_id)
    |> foreign_key_constraint(:user_documents_id)
    |> foreign_key_constraint(:user_education_id)
    |> foreign_key_constraint(:reviewed_by_id)
  end
end
