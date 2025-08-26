defmodule MyBelia.CourseLogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyBelia.CourseLogs` context.
  """

  @doc """
  Generate a course_log.
  """
  def course_log_fixture(attrs \\ %{}) do
    {:ok, course_log} =
      attrs
      |> Enum.into(%{
        title: "some title",
        description: "some description",
        status: "active",
        course_id: 42,
        instructor_id: 42
      })
      |> MyBelia.CourseLogs.create_course_log()

    course_log
  end
end
