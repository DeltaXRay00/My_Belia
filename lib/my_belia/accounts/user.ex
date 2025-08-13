defmodule MyBelia.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :full_name, :string
    field :role, :string, default: "user"
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation, :full_name, :role])
    |> validate_required([:email, :password, :password_confirmation, :full_name])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: hash_password(password))
  end

  defp put_password_hash(changeset), do: changeset

  defp hash_password(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16()
  end

  def verify_password(password, password_hash) do
    hash_password(password) == password_hash
  end
end
