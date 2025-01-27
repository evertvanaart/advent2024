defmodule Solutions.Day12.Common do
  @neighbors [
    {1, 0},
    {0, 1},
    {-1, 0},
    {0, -1}
  ]

  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {{i, j}, c} end)
    end)
    |> Enum.into(%{})
  end

  def get_neighbors(fields) do
    fields
    |> Enum.flat_map(fn pos ->
      @neighbors
      |> Enum.map(fn offset -> add_offset(pos, offset) end)
    end)
  end

  def add_offset({pi, pj}, {oi, oj}), do: {pi + oi, pj + oj}
end
