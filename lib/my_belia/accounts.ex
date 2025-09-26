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
  Gets a user with their educations preloaded.
  """
  def get_user_with_educations!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:user_educations)
  end

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
  Updates a user profile (without password validation).
  """
  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
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
    from(u in User, where: u.role == "admin")
    |> Repo.all()
  end

  @doc """
  Returns the list of superadmin users.
  """
  def list_superadmin_users do
    from(u in User, where: u.role == "superadmin")
    |> Repo.all()
  end

  @doc """
  Returns the list of regular users.
  """
  def list_regular_users do
    from(u in User, where: u.role == "user")
    |> Repo.all()
  end

  @doc """
  Gets a single user education.
  """
  def get_user_education!(id), do: Repo.get!(MyBelia.Accounts.UserEducation, id)

  @doc """
  Creates a user education.
  """
  def create_user_education(attrs \\ %{}) do
    %MyBelia.Accounts.UserEducation{}
    |> MyBelia.Accounts.UserEducation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user education.
  """
  def update_user_education(%MyBelia.Accounts.UserEducation{} = user_education, attrs) do
    user_education
    |> MyBelia.Accounts.UserEducation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user education.
  """
  def delete_user_education(%MyBelia.Accounts.UserEducation{} = user_education) do
    Repo.delete(user_education)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user education changes.
  """
  def change_user_education(%MyBelia.Accounts.UserEducation{} = user_education, attrs \\ %{}) do
    MyBelia.Accounts.UserEducation.changeset(user_education, attrs)
  end

  @doc """
  Deletes all user educations for a given user.
  """
  def delete_user_educations(user_id) do
    from(ue in MyBelia.Accounts.UserEducation, where: ue.user_id == ^user_id)
    |> Repo.delete_all()
  end

  # Add: fetch all user educations for a user_id
  def get_user_educations(user_id) do
    from(ue in MyBelia.Accounts.UserEducation, where: ue.user_id == ^user_id)
    |> Repo.all()
  end
end
