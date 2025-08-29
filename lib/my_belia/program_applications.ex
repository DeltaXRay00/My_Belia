defmodule MyBelia.ProgramApplications do
  @moduledoc """
  The ProgramApplications context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.ProgramApplications.ProgramApplication

  @doc """
  Returns the list of program_applications.

  ## Examples

      iex> list_program_applications()
      [%ProgramApplication{}, ...]

  """
  def list_program_applications do
    Repo.all(ProgramApplication)
  end

  @doc """
  Gets a single program_application.

  Raises `Ecto.NoResultsError` if the ProgramApplication does not exist.

  ## Examples

      iex> get_program_application!(123)
      %ProgramApplication{}

      iex> get_program_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_program_application!(id), do: Repo.get!(ProgramApplication, id)

  @doc """
  Creates a program_application.

  ## Examples

      iex> create_program_application(%{field: value})
      {:ok, %ProgramApplication{}}

      iex> create_program_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_program_application(attrs \\ %{}) do
    %ProgramApplication{}
    |> ProgramApplication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a program_application.

  ## Examples

      iex> update_program_application(program_application, %{field: new_value})
      {:ok, %ProgramApplication{}}

      iex> update_program_application(program_application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_program_application(%ProgramApplication{} = program_application, attrs) do
    program_application
    |> ProgramApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program_application.

  ## Examples

      iex> delete_program_application(program_application)
      {:ok, %ProgramApplication{}}

      iex> delete_program_application(program_application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_program_application(%ProgramApplication{} = program_application) do
    Repo.delete(program_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program_application changes.

  ## Examples

      iex> change_program_application(program_application)
      %Ecto.Changeset{data: %ProgramApplication{}}

  """
  def change_program_application(%ProgramApplication{} = program_application, attrs \\ %{}) do
    ProgramApplication.changeset(program_application, attrs)
  end

  @doc """
  Gets the count of applications for a specific program.
  """
  def get_program_applications_count(program_id) do
    ProgramApplication
    |> where(program_id: ^program_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets program applications for a specific program with user and program details.
  """
  def get_program_applications_with_details(program_id) do
    ProgramApplication
    |> where(program_id: ^program_id)
    |> preload([:user, :program, :reviewed_by])
    |> order_by([pa], [desc: pa.application_date])
    |> Repo.all()
  end

  @doc """
  Gets program applications for a specific program filtered by status.
  """
  def get_program_applications_by_status(program_id, status) do
    ProgramApplication
    |> where(program_id: ^program_id)
    |> where(status: ^status)
    |> preload([:user, :program, :reviewed_by])
    |> order_by([pa], [desc: pa.application_date])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific program.
  """
  def get_program_applications(program_id) do
    ProgramApplication
    |> where([pa], pa.program_id == ^program_id)
    |> preload([:user, :user_documents, :user_education, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all program applications with full details for admin view.
  """
  def list_program_applications_with_details() do
    ProgramApplication
    |> preload([:program, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all program applications by status for admin view.
  """
  def list_program_applications_by_status(status) do
    ProgramApplication
    |> where([pa], pa.status == ^status)
    |> preload([:program, :user, :user_documents, :user_education, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user.
  """
  def get_user_program_applications(user_id) do
    ProgramApplication
    |> where([pa], pa.user_id == ^user_id)
    |> preload([:program, :user_documents, :user_education, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user with full details.
  """
  def get_user_program_applications_with_details(user_id) do
    ProgramApplication
    |> where([pa], pa.user_id == ^user_id)
    |> preload([:program, :user, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user by status.
  """
  def get_user_program_applications_by_status(user_id, status) do
    ProgramApplication
    |> where([pa], pa.user_id == ^user_id and pa.status == ^status)
    |> preload([:program, :user, :reviewed_by])
    |> order_by([pa], [desc: pa.inserted_at])
    |> Repo.all()
  end

  @doc """
  Checks if a user has already applied for a specific program.
  """
  def user_has_applied_for_program?(user_id, program_id) do
    ProgramApplication
    |> where([pa], pa.user_id == ^user_id and pa.program_id == ^program_id)
    |> Repo.exists?()
  end

  @doc """
  Updates the status of a program application (admin review).
  """
  def update_application_status(application_id, status, admin_user_id, review_notes \\ nil) do
    attrs = %{
      status: status,
      reviewed_by_id: admin_user_id,
      review_date: Date.utc_today(),
      review_notes: review_notes
    }

    get_program_application!(application_id)
    |> update_program_application(attrs)
  end

  @doc """
  Gets application statistics for a program.
  """
  def get_program_application_stats(program_id) do
    ProgramApplication
    |> where([pa], pa.program_id == ^program_id)
    |> group_by([pa], pa.status)
    |> select([pa], {pa.status, count(pa.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end
end
