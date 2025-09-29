defmodule MyBeliaWeb.AdminController do
  use MyBeliaWeb, :controller
  alias MyBelia.Courses
  alias MyBelia.Programs
  alias MyBelia.Grants

  # Course CRUD operations
  def get_course(conn, %{"id" => id}) do
    try do
      course = Courses.get_course!(id)
      conn
      |> json(%{
        success: true,
        course: %{
          id: course.id,
          name: course.name,
          description: course.description,
          start_date: Date.to_string(course.start_date),
          end_date: Date.to_string(course.end_date),
          start_time: Time.to_string(course.start_time),
          end_time: Time.to_string(course.end_time),
          image_data: course.image_data
        }
      })
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Course not found"})
    end
  end

  def update_course(conn, %{"id" => id} = params) do
    course_params = params["course"]

    try do
      course = Courses.get_course!(id)

      # Ensure description is properly handled for WYSIWYG content
      updated_params = Map.put(course_params, "description", course_params["description"] || "")

      case Courses.update_course(course, updated_params) do
        {:ok, updated_course} ->
          conn
          |> json(%{success: true, course: updated_course})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, errors: format_changeset_errors(changeset)})
      end
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Course not found"})
    end
  end

  def create_course(conn, %{"course" => course_params}) do
    # Ensure description is properly handled for WYSIWYG content
    updated_params = Map.put(course_params, "description", course_params["description"] || "")

    case Courses.create_course(updated_params) do
      {:ok, course} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, course: course})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  end

  def delete_course(conn, %{"id" => id}) do
    try do
      course = Courses.get_course!(id)
      case Courses.delete_course(course) do
        {:ok, _} ->
          conn
          |> json(%{success: true})

        {:error, _} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, error: "Failed to delete course"})
      end
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Course not found"})
    end
  end

  # Program CRUD operations
  def get_program(conn, %{"id" => id}) do
    try do
      program = Programs.get_program!(id)
      conn
      |> json(%{
        success: true,
        program: %{
          id: program.id,
          name: program.name,
          description: program.description,
          start_date: Date.to_string(program.start_date),
          end_date: Date.to_string(program.end_date),
          start_time: Time.to_string(program.start_time),
          end_time: Time.to_string(program.end_time),
          image_data: program.image_data
        }
      })
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Program not found"})
    end
  end

  def update_program(conn, %{"id" => id} = params) do
    program_params = params["program"]

    try do
      program = Programs.get_program!(id)

      # Ensure description is properly handled for WYSIWYG content
      updated_params = Map.put(program_params, "description", program_params["description"] || "")

      case Programs.update_program(program, updated_params) do
        {:ok, updated_program} ->
          conn
          |> json(%{success: true, program: updated_program})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, errors: format_changeset_errors(changeset)})
      end
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Program not found"})
    end
  end

  def create_program(conn, %{"program" => program_params}) do
    # Ensure description is properly handled for WYSIWYG content
    updated_params = Map.put(program_params, "description", program_params["description"] || "")

    case Programs.create_program(updated_params) do
      {:ok, program} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, program: program})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  end

  def delete_program(conn, %{"id" => id}) do
    try do
      program = Programs.get_program!(id)
      case Programs.delete_program(program) do
        {:ok, _} ->
          conn
          |> json(%{success: true})

        {:error, _} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, error: "Failed to delete program"})
      end
    rescue
      Ecto.QueryError ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Program not found"})
    end
  end


  # Skim (Grant) CRUD operations
  def create_skim(conn, %{"skim" => skim_params}) do
    # Map frontend field names to database field names
    mapped_params = %{
      "nama_skim" => skim_params["name"],
      "diskripsi" => skim_params["description"] || "",
      "tujuan" => skim_params["purpose"] || "",
      "syarat_syarat" => skim_params["requirements"] || "",
      "skop_pembiayaan" => skim_params["scope"] || "",
      "had_pembiayaan" => skim_params["limit"] || "",
      "tempoh_pembiayaan" => skim_params["duration"] || "",
      "image_data" => skim_params["image_data"]
    }

    case Grants.create_grant(mapped_params) do
      {:ok, grant} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, grant: grant})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  end
  # Helper function to format changeset errors
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
