defmodule MyBelia.GrantApplications.GrantApplication do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBelia.Accounts.User

  schema "grant_applications" do
    field :grant_scheme, :string
    field :grant_amount, :decimal
    field :project_duration, :string
    field :project_name, :string
    field :project_objective, :string
    field :target_group, :string
    field :project_location, :string
    field :project_start_date, :date
    field :project_end_date, :date
    field :equipment_cost, :decimal, default: 0
    field :material_cost, :decimal, default: 0
    field :transport_cost, :decimal, default: 0
    field :admin_cost, :decimal, default: 0
    field :other_cost, :decimal, default: 0
    field :total_budget, :decimal, default: 0
    field :supporting_documents, {:array, :string}, default: []

    belongs_to :user, User

    timestamps()
  end

  @required ~w(grant_scheme project_name project_start_date project_end_date user_id)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, __schema__(:fields))
    |> validate_required(@required)
  end
end
