defmodule MyBelia.Grants.Grant do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :purpose, :requirements, :funding_scope, :funding_limit, :funding_period, :image_data, :image_url, :start_date, :end_date, :start_time, :end_time, :status, :created_by_id, :inserted_at, :updated_at]}

  alias MyBelia.Accounts.User

  schema "grants" do
    # Basic Information
    field :name, :string
    field :description, :string
    field :purpose, :string
    
    # Requirements and Conditions
    field :requirements, :string
    
    # Financing Information (matching database column names)
    field :funding_scope, :string
    field :funding_limit, :string
    field :funding_period, :string
    
    # Image Storage
    field :image_data, :binary
    field :image_url, :string
    
    # Application Period
    field :start_date, :date
    field :end_date, :date
    field :start_time, :time
    field :end_time, :time
    
    # System Fields
    field :status, :string, default: "active"
    belongs_to :created_by, User

    timestamps()
  end

  @required ~w(name)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [
      :name, :description, :purpose, :requirements, :funding_scope,
      :funding_limit, :funding_period, :image_data, :image_url, 
      :start_date, :end_date, :start_time, :end_time, :status, :created_by_id
    ])
    |> validate_required(@required)
  end
end
