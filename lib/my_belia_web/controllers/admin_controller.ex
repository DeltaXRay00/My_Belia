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
      "name" => skim_params["name"],
      "description" => skim_params["description"] || "",
      "purpose" => skim_params["purpose"] || "",
      "requirements" => skim_params["requirements"] || "",
      "funding_scope" => skim_params["scope"] || "",
      "funding_limit" => skim_params["limit"] || "",
      "funding_period" => skim_params["duration"] || "",
      "image_data" => skim_params["image_data"],
      "start_date" => skim_params["start_date"],
      "end_date" => skim_params["end_date"],
      "start_time" => skim_params["start_time"],
      "end_time" => skim_params["end_time"],
      "created_by_id" => get_current_user_id(conn)
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
  # Helper function to get current user ID
  defp get_current_user_id(conn) do
    # This is a placeholder - you may need to implement this based on your authentication system
    # For now, we will use a default admin user ID or nil
    case conn.assigns[:current_user] do
      %{id: user_id} -> user_id
      _ -> 1  # Default admin user ID - you should replace this with proper auth
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
