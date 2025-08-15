defmodule MyBelia.Repo.Migrations.AddImageDataToPrograms do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :image_data, :text
    end
  end
end
