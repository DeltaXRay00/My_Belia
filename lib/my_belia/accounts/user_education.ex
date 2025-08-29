defmodule MyBelia.Accounts.UserEducation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_educations" do
    field :education_level, :string
    field :institution, :string
    field :field_of_study, :string
    field :course, :string
    field :graduation_date, :date

    belongs_to :user, MyBelia.Accounts.User

    timestamps()
  end

  def changeset(user_education, attrs) do
    user_education
    |> cast(attrs, [:education_level, :institution, :field_of_study, :course, :graduation_date, :user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
