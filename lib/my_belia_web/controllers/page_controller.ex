defmodule MyBeliaWeb.PageController do
  use MyBeliaWeb, :controller

  alias MyBelia.Accounts

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    # The login page is often custom made,
    # so skip the default app layout.
    render(conn, :login, layout: false)
  end

  def login_post(conn, %{"user" => user_params}) do
    case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Log masuk berjaya!")
        |> redirect(to: if(user.role == "admin", do: "/admin", else: "/laman-utama-pengguna"))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Emel tidak dijumpai.")
        |> render(:login, layout: false)

      {:error, :invalid_password} ->
        conn
        |> put_flash(:error, "Kata laluan tidak betul.")
        |> render(:login, layout: false)
    end
  end

  def register(conn, _params) do
    # The register page is often custom made,
    # so skip the default app layout.
    render(conn, :register, layout: false)
  end

    def register_post(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Akaun berjaya dicipta! Sila log masuk.")
        |> redirect(to: "/log-masuk")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Ralat dalam pendaftaran. Sila cuba lagi.")
        |> render(:register, layout: false)
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Log keluar berjaya!")
    |> redirect(to: "/")
  end

  def user_home(conn, _params) do
    # The user home page is often custom made,
    # so skip the default app layout.
    render(conn, :user_home, layout: false)
  end

  def admin(conn, _params) do
    # The admin page is often custom made,
    # so skip the default app layout.
    render(conn, :admin, layout: false)
  end

  def admin_permohonan_program(conn, _params) do
    # The admin permohonan program page is often custom made,
    # so skip the default app layout.
    programs = MyBelia.Programs.list_programs()
    render(conn, :admin_permohonan_program, layout: false, programs: programs)
  end

  def create_program(conn, %{"program" => program_params}) do
    case MyBelia.Programs.create_program(program_params) do
      {:ok, program} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, program: %{
          id: program.id,
          name: program.name,
          description: program.description,
          image_data: program.image_data,
          start_date: Date.to_string(program.start_date),
          end_date: Date.to_string(program.end_date),
          start_time: Time.to_string(program.start_time),
          end_time: Time.to_string(program.end_time)
        }})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  end

  def get_program(conn, %{"id" => id}) do
    case MyBelia.Programs.get_program!(id) do
      program ->
        conn
        |> json(%{success: true, program: %{
          id: program.id,
          name: program.name,
          description: program.description,
          image_data: program.image_data,
          start_date: Date.to_string(program.start_date),
          end_date: Date.to_string(program.end_date),
          start_time: Time.to_string(program.start_time),
          end_time: Time.to_string(program.end_time)
        }})
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_status(:not_found)
      |> json(%{success: false, error: "Program tidak dijumpai"})
  end

  def update_program(conn, %{"id" => id, "program" => program_params}) do
    program = MyBelia.Programs.get_program!(id)
    case MyBelia.Programs.update_program(program, program_params) do
      {:ok, updated_program} ->
        conn
        |> json(%{success: true, program: %{
          id: updated_program.id,
          name: updated_program.name,
          description: updated_program.description,
          image_data: updated_program.image_data,
          start_date: Date.to_string(updated_program.start_date),
          end_date: Date.to_string(updated_program.end_date),
          start_time: Time.to_string(updated_program.start_time),
          end_time: Time.to_string(updated_program.end_time)
        }})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_status(:not_found)
      |> json(%{success: false, error: "Program tidak dijumpai"})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def admin_permohonan_kursus(conn, _params) do
    # The admin permohonan kursus page is often custom made,
    # so skip the default app layout.
    courses = MyBelia.Courses.list_courses()
    render(conn, :admin_permohonan_kursus, layout: false, courses: courses)
  end

  def admin_permohonan_geran(conn, _params) do
    # The admin permohonan geran page is often custom made,
    # so skip the default app layout.
    render(conn, :admin_permohonan_geran, layout: false)
  end

  def admin_permohonan_geran_lulus(conn, _params) do
    render(conn, :admin_permohonan_geran_lulus, layout: false)
  end

  def admin_permohonan_geran_tolak(conn, _params) do
    render(conn, :admin_permohonan_geran_tolak, layout: false)
  end

  def admin_permohonan_geran_tidak_lengkap(conn, _params) do
    render(conn, :admin_permohonan_geran_tidak_lengkap, layout: false)
  end

  def pemohon(conn, _params) do
    # The pemohon page is often custom made,
    # so skip the default app layout.
    render(conn, :pemohon, layout: false)
  end

  def pemohon_lulus(conn, _params) do
    # The pemohon lulus page is often custom made,
    # so skip the default app layout.
    render(conn, :pemohon_lulus, layout: false)
  end

  def pemohon_tolak(conn, _params) do
    # The pemohon tolak page is often custom made,
    # so skip the default app layout.
    render(conn, :pemohon_tolak, layout: false)
  end

  def pemohon_tidak_lengkap(conn, _params) do
    # The pemohon tidak lengkap page is often custom made,
    # so skip the default app layout.
    render(conn, :pemohon_tidak_lengkap, layout: false)
  end

  def kursus_pemohon(conn, _params) do
    # The kursus pemohon page is often custom made,
    # so skip the default app layout.
    render(conn, :kursus_pemohon, layout: false)
  end

  def kursus_pemohon_lulus(conn, _params) do
    # The kursus pemohon lulus page is often custom made,
    # so skip the default app layout.
    render(conn, :kursus_pemohon_lulus, layout: false)
  end

  def kursus_pemohon_tolak(conn, _params) do
    # The kursus pemohon tolak page is often custom made,
    # so skip the default app layout.
    render(conn, :kursus_pemohon_tolak, layout: false)
  end

  def kursus_pemohon_tidak_lengkap(conn, _params) do
    # The kursus pemohon tidak lengkap page is often custom made,
    # so skip the default app layout.
    render(conn, :kursus_pemohon_tidak_lengkap, layout: false)
  end

  def create_course(conn, %{"course" => course_params}) do
    case MyBelia.Courses.create_course(course_params) do
      {:ok, course} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, course: %{
          id: course.id,
          name: course.name,
          description: course.description,
          image_data: course.image_data,
          start_date: Date.to_string(course.start_date),
          end_date: Date.to_string(course.end_date),
          start_time: Time.to_string(course.start_time),
          end_time: Time.to_string(course.end_time)
        }})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  end

  def get_course(conn, %{"id" => id}) do
    case MyBelia.Courses.get_course!(id) do
      course ->
        conn
        |> json(%{success: true, course: %{
          id: course.id,
          name: course.name,
          description: course.description,
          image_data: course.image_data,
          start_date: Date.to_string(course.start_date),
          end_date: Date.to_string(course.end_date),
          start_time: Time.to_string(course.start_time),
          end_time: Time.to_string(course.end_time)
        }})
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_status(:not_found)
      |> json(%{success: false, error: "Kursus tidak dijumpai"})
  end

  def update_course(conn, %{"id" => id, "course" => course_params}) do
    course = MyBelia.Courses.get_course!(id)
    case MyBelia.Courses.update_course(course, course_params) do
      {:ok, updated_course} ->
        conn
        |> json(%{success: true, course: %{
          id: updated_course.id,
          name: updated_course.name,
          description: updated_course.description,
          image_data: updated_course.image_data,
          start_date: Date.to_string(updated_course.start_date),
          end_date: Date.to_string(updated_course.end_date),
          start_time: Time.to_string(updated_course.start_time),
          end_time: Time.to_string(updated_course.end_time)
        }})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: format_changeset_errors(changeset)})
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_status(:not_found)
      |> json(%{success: false, error: "Kursus tidak dijumpai"})
  end

  def user_profile(conn, _params) do
    # The user profile page is often custom made,
    # so skip the default app layout.
    render(conn, :user_profile, layout: false)
  end

  def example_user_page(conn, _params) do
    # Example page demonstrating reusable components
    render(conn, :example_user_page, layout: false)
  end

  def image_size_example(conn, _params) do
    # Example page demonstrating image size adjustments
    render(conn, :image_size_example, layout: false)
  end

  def search(conn, %{"q" => query}) do
    # General search functionality
    # This would search across programs, courses, and grants
    render(conn, :search_results, query: query, layout: false)
  end

  def search_programs(conn, %{"q" => query}) do
    # Search programs specifically
    render(conn, :search_programs, query: query, layout: false)
  end

  def search_courses(conn, %{"q" => query}) do
    # Search courses specifically
    render(conn, :search_courses, query: query, layout: false)
  end

  def dokumen_sokongan(conn, _params) do
    # The dokumen sokongan page is often custom made,
    # so skip the default app layout.
    render(conn, :dokumen_sokongan, layout: false)
  end

  def senarai_program(conn, _params) do
    # The senarai program page is often custom made,
    # so skip the default app layout.
    programs = MyBelia.Programs.list_programs()
    render(conn, :senarai_program, layout: false, programs: programs)
  end

  def senarai_kursus(conn, _params) do
    # The senarai kursus page is often custom made,
    # so skip the default app layout.
    courses = MyBelia.Courses.list_courses()
    render(conn, :senarai_kursus, layout: false, courses: courses)
  end

  def permohonan_geran(conn, _params) do
    # The permohonan geran page is often custom made,
    # so skip the default app layout.
    render(conn, :permohonan_geran, layout: false)
  end

  def skim_geran(conn, _params) do
    # The skim geran page is often custom made,
    # so skip the default app layout.
    render(conn, :skim_geran, layout: false)
  end

  def dokumen_sokongan_geran(conn, _params) do
    # The dokumen sokongan geran page is often custom made,
    # so skip the default app layout.
    render(conn, :dokumen_sokongan_geran, layout: false)
  end

  def pengesahan_permohonan(conn, _params) do
    # The pengesahan permohonan page is often custom made,
    # so skip the default app layout.
    render(conn, :pengesahan_permohonan, layout: false)
  end

  def program_detail(conn, %{"id" => id}) do
    case MyBelia.Programs.get_program!(id) do
      program ->
        render(conn, :program_detail, layout: false, program: program)
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_flash(:error, "Program tidak dijumpai")
      |> redirect(to: "/senarai_program")
  end

  def course_detail(conn, %{"id" => id}) do
    case MyBelia.Courses.get_course!(id) do
      course ->
        render(conn, :course_detail, layout: false, course: course)
    end
  rescue
    Ecto.QueryError ->
      conn
      |> put_flash(:error, "Kursus tidak dijumpai")
      |> redirect(to: "/senarai_kursus")
  end
end
