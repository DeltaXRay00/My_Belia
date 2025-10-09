defmodule Mix.Tasks.MyBelia.BackfillGrantDocs do
  use Mix.Task

  @shortdoc "Backfill grant supporting documents into user_documents"

  @moduledoc """
  Scans grant applications' supporting_documents and creates corresponding
  user_documents records when a matching file is found in priv/static/uploads/documents.

  Matching strategy per (user_id, index):
  - Expected grant types order:
    ["lesen_organisasi","profil_organisasi","surat_kebenaran","rancangan_atur_cara",
     "sijil_pengiktirafan","surat_rujukan","surat_sokongan","proposal"]
  - For each filename in supporting_documents, find a file in uploads/documents that either:
    a) starts with "<user_id>_<doc_type>_"
    b) equals the filename
    c) ends with "_filename"

  If found, inserts/updates a user_documents row pointing to that physical file via file_url.
  """

  alias MyBelia.Repo
  alias MyBelia.GrantApplications.GrantApplication
  alias MyBelia.Documents

  @types_order [
    "lesen_organisasi",
    "profil_organisasi",
    "surat_kebenaran",
    "rancangan_atur_cara",
    "sijil_pengiktirafan",
    "surat_rujukan",
    "surat_sokongan",
    "proposal"
  ]

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    apps = Repo.all(GrantApplication)
    base_dirs = discover_dirs()

    IO.puts("Backfilling #{length(apps)} grant application(s)...")

    for app <- apps do
      files = app.supporting_documents || []
      Enum.with_index(files)
      |> Enum.each(fn {filename, idx} ->
        doc_type = Enum.at(@types_order, idx, "proposal")
        case find_file(base_dirs, app.user_id, doc_type, filename) do
          nil ->
            IO.puts("[WARN] user=#{app.user_id} type=#{doc_type} filename=#{filename} -> file not found; skipped")
          found_name ->
            file_url = "/uploads/documents/#{found_name}"
            attrs = %{
              user_id: app.user_id,
              doc_type: doc_type,
              file_name: filename,
              file_url: file_url,
              content_type: guess_mime(filename)
            }
            case Documents.upsert_user_document(attrs) do
              {:ok, _} -> IO.puts("[OK] user=#{app.user_id} type=#{doc_type} -> #{found_name}")
              {:error, changeset} -> IO.puts("[ERR] user=#{app.user_id} type=#{doc_type} -> #{inspect(changeset.errors)}")
            end
        end
      end)
    end

    IO.puts("Backfill complete.")
  end

  defp discover_dirs do
    project_static = Path.expand(Path.join(["priv", "static", "uploads", "documents"]))
    app_static = :code.priv_dir(:my_belia) |> to_string() |> Path.join("static/uploads/documents")
    Enum.filter([project_static, app_static], &File.dir?/1)
  end

  defp list_files(dirs) do
    Enum.flat_map(dirs, fn dir ->
      case File.ls(dir) do
        {:ok, list} -> Enum.map(list, &{dir, &1})
        _ -> []
      end
    end)
  end

  defp find_file(dirs, user_id, doc_type, filename) do
    files = list_files(dirs)

    Enum.find_value(files, fn {_, name} ->
      cond do
        String.starts_with?(name, "#{user_id}_#{doc_type}_") -> name
        name == filename -> name
        String.ends_with?(name, "_#{filename}") -> name
        true -> false
      end
    end)
  end

  defp guess_mime(filename) do
    case MIME.from_path("/" <> filename) do
      "" -> "application/pdf"
      mime -> mime
    end
  end
end
