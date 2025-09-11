defmodule MyBelia.GrantApplications do
  @moduledoc """
  The GrantApplications context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.GrantApplications.GrantApplication

  @doc """
  Returns the list of grant_applications.
  """
  def list_grant_applications do
    Repo.all(GrantApplication)
  end

  @doc """
  Gets a single grant_application.
  Raises `Ecto.NoResultsError` if not found.
  """
  def get_grant_application!(id), do: Repo.get!(GrantApplication, id)

  @doc """
  Creates a grant_application.
  """
  def create_grant_application(attrs \\ %{}) do
    %GrantApplication{}
    |> GrantApplication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grant_application.
  """
  def update_grant_application(%GrantApplication{} = grant_application, attrs) do
    grant_application
    |> GrantApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a grant_application.
  """
  def delete_grant_application(%GrantApplication{} = grant_application) do
    Repo.delete(grant_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grant_application changes.
  """
  def change_grant_application(%GrantApplication{} = grant_application, attrs \\ %{}) do
    GrantApplication.changeset(grant_application, attrs)
  end

  @doc """
  Gets all grant applications with full details for admin view.
  Preloads the user and reviewer, sorted newest first.
  """
  def list_grant_applications_with_details do
    GrantApplication
    |> preload([:user, :reviewed_by])
    |> order_by([ga], [desc: ga.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all grant applications by status for admin view.
  """
  def list_grant_applications_by_status(status) do
    GrantApplication
    |> where([ga], ga.status == ^status)
    |> preload([:user, :reviewed_by])
    |> order_by([ga], [desc: ga.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets all applications for a specific user.
  """
  def get_user_grant_applications(user_id) do
    GrantApplication
    |> where([ga], ga.user_id == ^user_id)
    |> preload([:reviewed_by])
    |> order_by([ga], [desc: ga.inserted_at])
    |> Repo.all()
  end

  @doc """
  Updates the status of a grant application (admin review).
  Sets reviewer, date, and optional notes.
  """
  def update_application_status(application_id, status, admin_user_id, review_notes \\ nil) do
    attrs = %{
      status: status,
      reviewed_by_id: admin_user_id,
      review_date: Date.utc_today(),
      review_notes: review_notes
    }

    get_grant_application!(application_id)
    |> update_grant_application(attrs)
  end
end
