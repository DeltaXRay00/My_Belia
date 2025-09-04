defmodule MyBelia.CourseApplications do
  @moduledoc """
  The CourseApplications context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.CourseApplications.CourseApplication

  @doc """
  Returns the list of course_applications.

  ## Examples

      iex> list_course_applications()
      [%CourseApplication{}, ...]

  """
  def list_course_applications do
    Repo.all(CourseApplication)
  end

  @doc """
  Gets a single course_application.

  Raises `Ecto.NoResultsError` if the CourseApplication does not exist.

  ## Examples

      iex> get_course_application!(123)
      %CourseApplication{}

      iex> get_course_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course_application!(id), do: Repo.get!(CourseApplication, id)

  @doc """
  Creates a course_application.

  ## Examples

      iex> create_course_application(%{field: value})
      {:ok, %CourseApplication{}}

      iex> create_course_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course_application(attrs \\ %{}) do
    %CourseApplication{}
    |> CourseApplication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course_application.

  ## Examples

      iex> update_course_application(course_application, %{field: new_value})
      {:ok, %CourseApplication{}}

      iex> update_course_application(course_application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course_application(%CourseApplication{} = course_application, attrs) do
    course_application
    |> CourseApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course_application.

  ## Examples

      iex> delete_course_application(course_application)
      {:ok, %CourseApplication{}}

      iex> delete_course_application(course_application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course_application(%CourseApplication{} = course_application) do
    Repo.delete(course_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course_application changes.

  ## Examples

      iex> change_course_application(course_application)
      %Ecto.Changeset{data: %CourseApplication{}}

  """
  def change_course_application(%CourseApplication{} = course_application, attrs \\ %{}) do
    CourseApplication.changeset(course_application, attrs)
  end

  @doc """
  Gets the count of applications for a specific course.
  """
  def get_course_applications_count(course_id) do
    CourseApplication
    |> where(course_id: ^course_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets all applications for a specific course.
  """
  def get_course_applications(course_id) do
    CourseApplication
    |> where([ca], ca.course_id == ^course_id)
    |> preload([:user, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific course with full details for admin view.
  """
  def get_course_applications_with_details(course_id) do
    CourseApplication
    |> where([ca], ca.course_id == ^course_id)
    |> preload([:course, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific course by status for admin view.
  """
  def get_course_applications_by_status(course_id, status) do
    CourseApplication
    |> where([ca], ca.course_id == ^course_id and ca.status == ^status)
    |> preload([:course, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all course applications with full details for admin view.
  """
  def list_course_applications_with_details() do
    CourseApplication
    |> preload([:course, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all course applications by status for admin view.
  """
  def list_course_applications_by_status(status) do
    CourseApplication
    |> where([ca], ca.status == ^status)
    |> preload([:course, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user.
  """
  def get_user_course_applications(user_id) do
    CourseApplication
    |> where([ca], ca.user_id == ^user_id)
    |> preload([:course, :user_documents, :user_education, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user with full details.
  """
  def get_user_course_applications_with_details(user_id) do
    CourseApplication
    |> where([ca], ca.user_id == ^user_id)
    |> preload([:course, :user, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user by status.
  """
  def get_user_course_applications_by_status(user_id, status) do
    CourseApplication
    |> where([ca], ca.user_id == ^user_id and ca.status == ^status)
    |> preload([:course, :user, :reviewed_by])
    |> order_by([ca], [desc: ca.inserted_at])
    |> Repo.all()
  end

  @doc """
  Checks if a user has already applied for a specific course.
  """
  def user_has_applied_for_course?(user_id, course_id) do
    CourseApplication
    |> where([ca], ca.user_id == ^user_id and ca.course_id == ^course_id)
    |> Repo.exists?()
  end

  @doc """
  Updates the status of a course application (admin review).
  """
  def update_application_status(application_id, status, admin_user_id, review_notes \\ nil) do
    attrs = %{
      status: status,
      reviewed_by_id: admin_user_id,
      review_date: Date.utc_today(),
      review_notes: review_notes
    }

    get_course_application!(application_id)
    |> update_course_application(attrs)
  end

  @doc """
  Gets application statistics for a course.
  """
  def get_course_application_stats(course_id) do
    CourseApplication
    |> where([ca], ca.course_id == ^course_id)
    |> group_by([ca], ca.status)
    |> select([ca], {ca.status, count(ca.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end
end
