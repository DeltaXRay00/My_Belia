defmodule MyBelia.Repo.Migrations.NormalizeStatusValues do
  use Ecto.Migration

  def up do
    execute("UPDATE program_applications SET status = 'tidak_lengkap' WHERE status = 'tidak lengkap'")
    execute("UPDATE course_applications SET status = 'tidak_lengkap' WHERE status = 'tidak lengkap'")
  end

  def down do
    execute("UPDATE program_applications SET status = 'tidak lengkap' WHERE status = 'tidak_lengkap'")
    execute("UPDATE course_applications SET status = 'tidak lengkap' WHERE status = 'tidak_lengkap'")
  end
end
