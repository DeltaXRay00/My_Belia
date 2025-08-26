defmodule MyBelia.CourseLogs do
  @moduledoc """
  The CourseLogs context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.CourseLogs.CourseLog

  @doc """
  Returns the list of course_logs.

  ## Examples

      iex> list_course_logs()
      [%CourseLog{}, ...]

  """
  def list_course_logs do
    Repo.all(CourseLog)
  end

  @doc """
  Gets a single course_log.

  Raises `Ecto.NoResultsError` if the CourseLog does not exist.

  ## Examples

      iex> get_course_log!(123)
      %CourseLog{}

      iex> get_course_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course_log!(id), do: Repo.get!(CourseLog, id)

  @doc """
  Creates a course_log.

  ## Examples

      iex> create_course_log(%{field: value})
      {:ok, %CourseLog{}}

      iex> create_course_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course_log(attrs \\ %{}) do
    %CourseLog{}
    |> CourseLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course_log.

  ## Examples

      iex> update_course_log(course_log, %{field: new_value})
      {:ok, %CourseLog{}}

      iex> update_course_log(course_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course_log(%CourseLog{} = course_log, attrs) do
    course_log
    |> CourseLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course_log.

  ## Examples

      iex> delete_course_log(course_log)
      {:ok, %CourseLog{}}

      iex> delete_course_log(course_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course_log(%CourseLog{} = course_log) do
    Repo.delete(course_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course_log changes.

  ## Examples

      iex> change_course_log(course_log)
      %Ecto.Changeset{data: %CourseLog{}}

  """
  def change_course_log(%CourseLog{} = course_log, attrs \\ %{}) do
    CourseLog.changeset(course_log, attrs)
  end
end
