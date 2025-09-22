defmodule Mix.Tasks.MyBelia.LinkGrantDocuments do
  use Mix.Task

  def run(_args) do
    Mix.Task.run("app.start")
    IO.puts("Linking grant applications to documents...")
    
    applications = MyBelia.GrantApplications.list_grant_applications()
    
    Enum.each(applications, fn app ->
      link_documents_for_app(app)
    end)
    
    IO.puts("Done!")
  end

  defp link_documents_for_app(app) do
    user_id = app.user_id
    
    documents = MyBelia.Documents.list_grant_user_documents(user_id)
    
    updates = %{}
    |> maybe_link_doc(documents, "surat_sokongan", :surat_sokongan_id)
    |> maybe_link_doc(documents, "profil_organisasi", :profil_organisasi_id)
    |> maybe_link_doc(documents, "surat_kebenaran", :surat_kebenaran_id)
    |> maybe_link_doc(documents, "rancangan_atur_cara", :rancangan_atur_cara_id)
    |> maybe_link_doc(documents, "lesen_organisasi", :lesen_organisasi_id)
    |> maybe_link_doc(documents, "sijil_pengiktirafan", :sijil_pengiktirafan_id)
    |> maybe_link_doc(documents, "surat_rujukan", :surat_rujukan_id)
    
    if map_size(updates) > 0 do
      case MyBelia.GrantApplications.update_grant_application(app, updates) do
        {:ok, _} -> IO.puts("Linked documents for app #{app.id}")
        {:error, _} -> IO.puts("Error linking app #{app.id}")
      end
    end
  end

  defp maybe_link_doc(updates, documents, doc_type, field_name) do
    case Enum.find(documents, &(&1.doc_type == doc_type)) do
      nil -> updates
      doc -> Map.put(updates, field_name, doc.id)
    end
  end
end
