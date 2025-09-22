defmodule MyBeliaWeb.DocumentController do
  use MyBeliaWeb, :controller

  alias MyBelia.Documents

  defp serve_document(conn, doc) do
    url = doc.file_url

    cond do
      is_binary(url) and (String.starts_with?(url, "http://") or String.starts_with?(url, "https://")) ->
        redirect(conn, external: url)

      is_binary(url) and String.starts_with?(url, "data:") ->
        redirect(conn, external: url)

      is_binary(url) and String.starts_with?(url, "base64:") ->
        base = String.replace_prefix(url, "base64:", "")
        binary = Base.decode64!(base)
        content_type = doc.content_type || "application/pdf"
        filename = doc.file_name || "document.pdf"

        conn
        |> put_resp_header("content-type", content_type)
        |> put_resp_header("content-disposition", ~s(inline; filename="#{filename}"))
        |> send_resp(200, binary)

      is_binary(url) and String.starts_with?(url, "/") ->
        # Serve local file from priv/static when given a site-relative URL (e.g. /uploads/...)
        rel_path = url |> String.trim_leading("/") |> URI.decode()
        project_static_dir = Path.expand(Path.join(["priv", "static"]))
        app_priv = :code.priv_dir(:my_belia) |> to_string()
        app_static_dir = Path.join(app_priv, "static")
        app_dir_static = Path.join(Application.app_dir(:my_belia), "priv/static")
        candidate_paths = [
          Path.join(project_static_dir, rel_path),
          Path.join(app_static_dir, rel_path),
          Path.join(app_dir_static, rel_path)
        ]
        file_path = Enum.find(candidate_paths, &File.exists?/1)
        file_path =
          if is_nil(file_path) do
            # Fallback: try to find by prefix pattern userId_docType_*.pdf in uploads/documents
            uploads_dir = Path.join(project_static_dir, "uploads/documents")
            files = case File.ls(uploads_dir) do
              {:ok, list} -> list
              _ -> []
            end

            prefix = "#{doc.user_id}_#{doc.doc_type}_"
            alt = Enum.find(files, fn name -> String.starts_with?(name, prefix) end)

            alt2 = if is_nil(alt) do
              # Fallback 2: match by doc_type and original filename suffix (ignore user_id)
              Enum.find(files, fn name ->
                String.contains?(name, "_#{doc.doc_type}_") and String.ends_with?(name, "_#{doc.file_name}")
              end)
            else
              nil
            end

            chosen = alt || alt2
            if chosen, do: Path.join(uploads_dir, chosen), else: nil
          else
            file_path
          end

        if is_nil(file_path) do
          require Logger
          Logger.error("Document not found. Tried: #{Enum.join(candidate_paths, "; ")}")
          send_resp(conn, 404, "Document file not found")
        else
          content_type = doc.content_type || "application/pdf"
          filename = doc.file_name || Path.basename(file_path)
          conn
          |> put_resp_header("content-type", content_type)
          |> put_resp_header("content-disposition", ~s(inline; filename="#{filename}"))
          |> send_file(200, file_path)
        end

      true ->
        send_resp(conn, 404, "Document not found")
    end
  end

  def show(conn, %{"id" => id}) do
    doc = Documents.get_user_document!(id)
    serve_document(conn, doc)
  end

  def show_by_type(conn, %{"user_id" => user_id, "doc_type" => doc_type}) do
    case Documents.get_user_document_by(user_id, doc_type) do
      nil -> send_resp(conn, 404, "Document not found")
      doc -> serve_document(conn, doc)
    end
  end

  # Serve grant doc by type: finds the first matching stored name "<user>_<type>_*"
  def show_grant_by_type(conn, %{"user_id" => user_id, "doc_type" => doc_type}) do
    # 1) Prefer DB entry (same mechanism used by program/courses)
    case Documents.get_user_document_by(user_id, doc_type) do
      %Documents.UserDocument{} = doc ->
        serve_document(conn, doc)

      _ ->
        # 2) Fallback to filesystem scan: <user>_<doc_type>_*
        project_static_dir = Path.expand(Path.join(["priv", "static"]))
        app_static_dir = :code.priv_dir(:my_belia) |> to_string() |> Path.join("static")
        dirs = [Path.join(project_static_dir, "uploads/documents"), Path.join(app_static_dir, "uploads/documents")]

        files = Enum.flat_map(dirs, fn dir ->
          case File.ls(dir) do
            {:ok, list} -> Enum.map(list, &{dir, &1})
            _ -> []
          end
        end)

        match = Enum.find(files, fn {_, name} -> String.starts_with?(name, "#{user_id}_#{doc_type}_") end)

        case match do
          {dir, name} ->
            path = Path.join(dir, name)
            content_type = MIME.from_path("/#{name}") || "application/pdf"
            conn
            |> put_resp_header("content-type", content_type)
            |> put_resp_header("content-disposition", ~s(inline; filename="#{name}") )
            |> send_file(200, path)
          _ -> send_resp(conn, 404, "Document not found")
        end
    end
  end

  # Serve by filename for grant form supporting_documents which only store names
  def show_by_filename(conn, %{"user_id" => user_id, "filename" => filename}) do
    # Normalize
    fname = URI.decode(filename)

    project_static_dir = Path.expand(Path.join(["priv", "static"]))
    app_static_dir = :code.priv_dir(:my_belia) |> to_string() |> Path.join("static")
    dirs = [Path.join(project_static_dir, "uploads/documents"), Path.join(app_static_dir, "uploads/documents")]

    files = Enum.flat_map(dirs, fn dir ->
      case File.ls(dir) do
        {:ok, list} -> Enum.map(list, &{dir, &1})
        _ -> []
      end
    end)

    # Match strategies
    candidates = Enum.filter(files, fn {_, name} ->
      String.starts_with?(name, "#{user_id}_") and String.ends_with?(name, "_#{fname}")
    end)

    alt = if candidates == [] do
      Enum.filter(files, fn {_, name} -> name == fname or String.ends_with?(name, fname) end)
    else
      candidates
    end

    case alt do
      [{dir, found} | _] ->
        path = Path.join(dir, found)
        doc = %MyBelia.Documents.UserDocument{
          file_url: "/uploads/documents/#{found}",
          file_name: fname,
          content_type: MIME.from_path("/#{fname}") || "application/pdf"
        }
        # Serve directly from disk to avoid route issues
        if File.exists?(path) do
          conn
          |> put_resp_header("content-type", doc.content_type)
          |> put_resp_header("content-disposition", ~s(inline; filename="#{doc.file_name}"))
          |> send_file(200, path)
        else
          serve_document(conn, doc)
        end
      _ -> send_resp(conn, 404, "Document not found")
    end
  end
end
