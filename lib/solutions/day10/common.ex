defmodule Solutions.Day10.Common do
  @neighbors [
    {1, 0},
    {0, 1},
    {-1, 0},
    {0, -1}
  ]

  # -------------------------------- Recursion ------------------------------- #

  def find_peaks(grid, position, 9) do
    if Map.get(grid, position, nil) == 9, do: [position], else: []
  end

  def find_peaks(grid, position, value) do
    if Map.get(grid, position, nil) == value do
      @neighbors
      |> Enum.map(fn offset -> add_offset(position, offset) end)
      |> Enum.flat_map(fn next -> find_peaks(grid, next, value + 1) end)
    else
      []
    end
  end

  def add_offset({pi, pj}, {oi, oj}), do: {pi + oi, pj + oj}

  # ------------------------------ Parsing input ----------------------------- #

  def get_starts(grid) do
    grid
    |> Enum.filter(fn {_, v} -> v == 0 end)
    |> Enum.map(fn {pos, _} -> pos end)
  end

  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, j} -> {{i, j}, v} end)
    end)
    |> Enum.into(%{})
  end
end
