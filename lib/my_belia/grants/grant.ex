defmodule MyBelia.Grants.Grant do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBelia.Accounts.User

  schema "grants" do
    field :nama_skim, :string
    field :diskripsi, :string
    field :tujuan, :string
    field :syarat_syarat, :string
    field :skop_pembiayaan, :string
    field :had_pembiayaan, :decimal
    field :tempoh_pembiayaan, :string
    field :image_data, :binary
    field :image_url, :string
    field :status, :string, default: "active"

    belongs_to :created_by, User

    timestamps()
  end

  @required ~w(nama_skim)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [
      :nama_skim, :diskripsi, :tujuan, :syarat_syarat, :skop_pembiayaan,
      :had_pembiayaan, :tempoh_pembiayaan, :image_data, :image_url, :status, :created_by_id
    ])
    |> validate_required(@required)
  end
end