defmodule MyBelia.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Authenticates a user by email and password.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    case user do
      nil ->
        {:error, :not_found}
      user ->
        if User.verify_password(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end

  @doc """
  Returns the list of admin users (excluding superadmin).
  """
  def list_admin_users do
    User
    |> where([u], u.role == "admin")
    |> order_by([u], u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of superadmin users.
  """
  def list_superadmin_users do
    User
    |> where([u], u.role == "superadmin")
    |> order_by([u], u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of all admin users (both admin and superadmin).
  """
  def list_all_admin_users do
    User
    |> where([u], u.role == "admin" or u.role == "superadmin")
    |> order_by([u], u.inserted_at)
    |> Repo.all()
  end

  # User Education functions
  alias MyBelia.Accounts.UserEducation

  @doc """
  Gets a user with their education records.
  """
  def get_user_with_educations!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:user_educations)
  end

  @doc """
  Creates a user education record.
  """
  def create_user_education(attrs \\ %{}) do
    %UserEducation{}
    |> UserEducation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user education record.
  """
  def update_user_education(%UserEducation{} = user_education, attrs) do
    user_education
    |> UserEducation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user education record.
  """
  def delete_user_education(%UserEducation{} = user_education) do
    Repo.delete(user_education)
  end

  @doc """
  Gets user education records by user ID.
  """
  def get_user_educations(user_id) do
    UserEducation
    |> where([ue], ue.user_id == ^user_id)
    |> order_by([ue], ue.inserted_at)
    |> Repo.all()
  end

  @doc """
  Deletes all education records for a user.
  """
  def delete_user_educations(user_id) do
    UserEducation
    |> where([ue], ue.user_id == ^user_id)
    |> Repo.delete_all()
  end
end
