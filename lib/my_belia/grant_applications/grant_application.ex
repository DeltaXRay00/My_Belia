defmodule MyBelia.GrantApplications.GrantApplication do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBelia.Accounts.User

  schema "grant_applications" do
    # Organization info
    field :organization_name, :string
    field :registration_number, :string
    field :organization_type, :string
    field :established_date, :date
    field :address, :string
    field :postcode, :string
    field :district, :string

    # Contact info
    field :office_phone, :string
    field :mobile_phone, :string
    field :email, :string
    field :website, :string
    field :social_media, :string

    # Membership/activity
    field :total_members, :integer
    field :youth_members, :integer
    field :activity_field, :string

    # Bank info
    field :bank_name, :string
    field :account_holder, :string
    field :account_number, :string

    # Project/Grant info
    field :grant_scheme, :string
    field :grant_amount, :decimal
    field :project_duration, :string
    field :project_name, :string
    field :project_objective, :string
    field :target_group, :string
    field :project_location, :string
    field :project_start_date, :date
    field :project_end_date, :date

    # Budget
    field :equipment_cost, :decimal, default: 0
    field :material_cost, :decimal, default: 0
    field :transport_cost, :decimal, default: 0
    field :admin_cost, :decimal, default: 0
    field :other_cost, :decimal, default: 0
    field :total_budget, :decimal, default: 0

    # Document relationships
    belongs_to :surat_sokongan, MyBelia.Documents.UserDocument
    belongs_to :profil_organisasi, MyBelia.Documents.UserDocument
    belongs_to :surat_kebenaran, MyBelia.Documents.UserDocument
    belongs_to :rancangan_atur_cara, MyBelia.Documents.UserDocument
    belongs_to :lesen_organisasi, MyBelia.Documents.UserDocument
    belongs_to :sijil_pengiktirafan, MyBelia.Documents.UserDocument
    belongs_to :surat_rujukan, MyBelia.Documents.UserDocument

    # Legacy field (keep for backward compatibility)
    field :supporting_documents, {:array, :string}, default: []

    # Status
    field :status, :string, default: "pending"

    belongs_to :user, User
    belongs_to :reviewed_by, User

    timestamps()
  end

  @required ~w(user_id grant_scheme project_name project_start_date project_end_date)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [
      :user_id,
      # organization
      :organization_name, :registration_number, :organization_type, :established_date,
      :address, :postcode, :district,
      # contact
      :office_phone, :mobile_phone, :email, :website, :social_media,
      # membership/activity
      :total_members, :youth_members, :activity_field,
      # bank
      :bank_name, :account_holder, :account_number,
      # project
      :grant_scheme, :grant_amount, :project_duration, :project_name, :project_objective,
      :target_group, :project_location, :project_start_date, :project_end_date,
      # budget
      :equipment_cost, :material_cost, :transport_cost, :admin_cost, :other_cost, :total_budget,
      # document relationships
      :surat_sokongan_id, :profil_organisasi_id, :surat_kebenaran_id, :rancangan_atur_cara_id,
      :lesen_organisasi_id, :sijil_pengiktirafan_id, :surat_rujukan_id,
      # files/status
      :supporting_documents, :status
    ])
    |> validate_required(@required)
  end
end

