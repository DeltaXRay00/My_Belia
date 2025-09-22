defmodule MyBelia.Repo.Migrations.AddDocumentRelationshipsToGrantApplications do
  use Ecto.Migration

  def change do
    alter table(:grant_applications) do
      add :surat_sokongan_id, references(:user_documents, on_delete: :nilify_all)
      add :profil_organisasi_id, references(:user_documents, on_delete: :nilify_all)
      add :surat_kebenaran_id, references(:user_documents, on_delete: :nilify_all)
      add :rancangan_atur_cara_id, references(:user_documents, on_delete: :nilify_all)
      add :lesen_organisasi_id, references(:user_documents, on_delete: :nilify_all)
      add :sijil_pengiktirafan_id, references(:user_documents, on_delete: :nilify_all)
      add :surat_rujukan_id, references(:user_documents, on_delete: :nilify_all)
    end

    create index(:grant_applications, [:surat_sokongan_id])
    create index(:grant_applications, [:profil_organisasi_id])
    create index(:grant_applications, [:surat_kebenaran_id])
    create index(:grant_applications, [:rancangan_atur_cara_id])
    create index(:grant_applications, [:lesen_organisasi_id])
    create index(:grant_applications, [:sijil_pengiktirafan_id])
    create index(:grant_applications, [:surat_rujukan_id])
  end
end
