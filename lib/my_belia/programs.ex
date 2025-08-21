defmodule MyBelia.Programs do
  @moduledoc """
  The Programs context.
  """

  import Ecto.Query, warn: false
  alias MyBelia.Repo
  alias MyBelia.Program

  @doc """
  Returns the list of programs.
  """
  def list_programs do
    Repo.all(Program) |> Repo.preload([])
  end

  @doc """
  Gets a single program.
  """
  def get_program!(id), do: Repo.get!(Program, id)

  @doc """
  Creates a program.
  """
  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a program.
  """
  def update_program(%Program{} = program, attrs) do
    program
    |> Program.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program.
  """
  def delete_program(%Program{} = program) do
    Repo.delete(program)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program changes.
  """
  def change_program(%Program{} = program, attrs \\ %{}) do
    Program.changeset(program, attrs)
  end

  @doc """
  Search programs by name or description.
  """
  def search_programs(query) when is_binary(query) and byte_size(query) > 0 do
    search_term = "%#{query}%"

    Program
    |> where([p], ilike(p.name, ^search_term) or ilike(p.description, ^search_term))
    |> Repo.all()
  end

  def search_programs(_), do: []

  @doc """
  Deletes all programs from the database.
  """
  def delete_all_programs do
    Repo.delete_all(Program)
  end
end
