defmodule MyBelia.Course do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :image_data, :start_date, :end_date, :start_time, :end_time, :inserted_at, :updated_at]}

  schema "courses" do
    field :name, :string
    field :description, :string
    field :image_data, :string
    field :start_date, :date
    field :end_date, :date
    field :start_time, :time
    field :end_time, :time

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :image_data, :start_date, :end_date, :start_time, :end_time])
    |> validate_required([:name, :description, :image_data, :start_date, :end_date, :start_time, :end_time])
    |> validate_date_range()
  end

  defp validate_date_range(changeset) do
    case {get_field(changeset, :start_date), get_field(changeset, :end_date)} do
      {start_date, end_date} when not is_nil(start_date) and not is_nil(end_date) ->
        if Date.compare(start_date, end_date) == :gt do
          add_error(changeset, :end_date, "Tarikh tamat mesti selepas tarikh mula")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end
