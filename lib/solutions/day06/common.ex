defmodule Solutions.Day06.Common do
  # ------------------------------ Path tracing ------------------------------ #

  def trace_path(grid, position, direction, visited) do
    new_visited = MapSet.put(visited, position)
    next_position = next_pos(position, direction)
    next_cell = Map.get(grid, next_position, :exit)

    case next_cell do
      :empty -> trace_path(grid, next_position, direction, new_visited)
      :block -> trace_path(grid, position, next_dir(direction), new_visited)
      :exit -> new_visited
    end
  end

  def next_pos({i, j}, :n), do: {i - 1, j}
  def next_pos({i, j}, :e), do: {i, j + 1}
  def next_pos({i, j}, :s), do: {i + 1, j}
  def next_pos({i, j}, :w), do: {i, j - 1}

  def next_dir(:n), do: :e
  def next_dir(:e), do: :s
  def next_dir(:s), do: :w
  def next_dir(:w), do: :n

  # --------------------------------- Parsing -------------------------------- #

  def find_start(lines) do
    {line, row} =
      lines
      |> Enum.with_index()
      |> Enum.find(fn {line, _} -> String.contains?(line, "^") end)

    {_, col} =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.find(fn {ch, _} -> ch == "^" end)

    {row, col}
  end

  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {{i, j}, get_cell_type(c)} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp get_cell_type("."), do: :empty
  defp get_cell_type("^"), do: :empty
  defp get_cell_type("#"), do: :block
end
