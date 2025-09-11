defmodule MyBeliaWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the page_html directory for all templates available.
  """
  use MyBeliaWeb, :html

  import MyBeliaWeb.UserComponents

  # Import form helpers from phoenix_html_helpers
  import PhoenixHTMLHelpers.Form

  embed_templates "page_html/*"

  # Helper function to format file sizes
  def format_file_size(bytes) when is_integer(bytes) do
    cond do
      bytes < 1024 -> "#{bytes} B"
      bytes < 1024 * 1024 -> "#{Float.round(bytes / 1024, 1)} KB"
      bytes < 1024 * 1024 * 1024 -> "#{Float.round(bytes / (1024 * 1024), 1)} MB"
      true -> "#{Float.round(bytes / (1024 * 1024 * 1024), 1)} GB"
    end
  end

  def format_file_size(_), do: "0 B"
end
