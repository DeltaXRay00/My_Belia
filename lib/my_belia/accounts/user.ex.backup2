defmodule MyBelia.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :full_name, :string
    field :daerah, :string
    field :role, :string, default: "user"
    field :status, :string, default: "active"
    field :last_login, :utc_datetime
    field :jawatan, :string
    field :unit_bahagian, :string

    # Optional Profile Fields (for /profil_pengguna)
    field :ic_number, :string
    field :birth_date, :date
    field :birth_place, :string
    field :gender, :string
    field :phone_number, :string
    field :religion, :string
    field :race, :string
    field :residential_address, :string
    field :mailing_address, :string
    field :education_level, :string
    field :institution, :string
    field :field_of_study, :string
    field :course, :string
    field :graduation_date, :date
    field :avatar_url, :string

    # Associations
    has_many :user_educations, MyBelia.Accounts.UserEducation, on_delete: :delete_all
    has_many :user_documents, MyBelia.Documents.UserDocument, on_delete: :delete_all

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email, :password, :password_confirmation, :full_name, :daerah,
      :role, :status, :last_login, :jawatan, :unit_bahagian,
      :ic_number, :birth_date, :birth_place, :gender, :phone_number,
      :religion, :race, :residential_address, :mailing_address,
      :education_level, :institution, :field_of_study, :course, :graduation_date,
      :avatar_url
    ])
    |> validate_required([:email, :full_name])
    |> validate_format(:email, ~r/@/)
    |> validate_password()
    |> unique_constraint(:email)
    |> put_password_hash()
  end

    defp validate_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        # No password change, skip password validation
        changeset
      _password ->
        # Password is being changed, validate it
        changeset
        |> validate_length(:password, min: 6)
        |> validate_confirmation(:password)
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: hash_password(password))
  end

  defp put_password_hash(changeset), do: changeset

  defp hash_password(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16()
  end

  def verify_password(password, password_hash) do
    hash_password(password) == password_hash
  end
end
