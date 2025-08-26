defmodule MyBelia.CourseLogs.CourseLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_logs" do
    field :title, :string
    field :description, :string
    field :status, :string
    field :course_id, :integer
    field :instructor_id, :integer

    timestamps()
  end

  @doc false
  def changeset(course_log, attrs) do
    course_log
    |> cast(attrs, [:title, :description, :status, :course_id, :instructor_id])
    |> validate_required([:title, :description, :status, :course_id, :instructor_id])
  end
end
