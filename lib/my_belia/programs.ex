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
end
