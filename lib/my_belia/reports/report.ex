defmodule MyBelia.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :title, :string
    field :description, :string
    field :status, :string

    belongs_to :program, MyBelia.Program
    belongs_to :course, MyBelia.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:title, :description, :status, :program_id, :course_id])
    |> validate_required([:title, :description, :status])
    |> foreign_key_constraint(:program_id)
    |> foreign_key_constraint(:course_id)
  end
end
