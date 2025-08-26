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
end
