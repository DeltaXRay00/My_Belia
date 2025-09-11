defmodule MyBelia.GrantFormState do
  @moduledoc """
  Keeps temporary grant form data in memory across multiple LiveView steps.
  """
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Get data for a given session
  def get_form_data(session_id) when is_binary(session_id) do
    Agent.get(__MODULE__, &Map.get(&1, session_id, %{}))
  end

  # Store a whole map
  def store_form_data(session_id, data) when is_map(data) do
    Agent.update(__MODULE__, &Map.put(&1, session_id, data))
  end

  # Merge into existing
  def update_form_data(session_id, new_data) when is_map(new_data) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, session_id, new_data, &Map.merge(&1, new_data))
    end)
  end

  # Clear data after submission
  def delete_form_data(session_id) do
    Agent.update(__MODULE__, &Map.delete(&1, session_id))
  end
end
