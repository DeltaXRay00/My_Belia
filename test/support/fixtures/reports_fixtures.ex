defmodule MyBelia.ReportsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyBelia.Reports` context.
  """

  @doc """
  Generate a report.
  """
  def report_fixture(attrs \\ %{}) do
    {:ok, report} =
      attrs
      |> Enum.into(%{
        title: "some title",
        content: "some content"
      })
      |> MyBelia.Reports.create_report()

    report
  end
end
