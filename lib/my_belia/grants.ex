defmodule MyBelia.Grants do
  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.Grants.Grant

  def list_grants do
    Repo.all(Grant)
  end

  def get_grant!(id), do: Repo.get!(Grant, id)

  def create_grant(attrs \\ %{}) do
    %Grant{}
    |> Grant.changeset(attrs)
    |> Repo.insert()
  end

  def update_grant(%Grant{} = grant, attrs) do
    grant
    |> Grant.changeset(attrs)
    |> Repo.update()
  end

  def delete_grant(%Grant{} = grant) do
    Repo.delete(grant)
  end

  def change_grant(%Grant{} = grant, attrs \\ %{}) do
    Grant.changeset(grant, attrs)
  end
end