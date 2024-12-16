defmodule Solutions.Day16.Common do
  # -------------------------------- Constants ------------------------------- #

  @neighbors [
    {{1, 0}, :d},
    {{0, 1}, :r},
    {{-1, 0}, :u},
    {{0, -1}, :l}
  ]

  # ---------------------------- Utility functions --------------------------- #

  def get_open_neighbors(grid, {pi, pj}) do
    @neighbors
    |> Enum.map(fn {{oi, oj}, dir} -> {{pi + oi, pj + oj}, dir} end)
    |> Enum.filter(fn {neighbor, _} -> Map.get(grid, neighbor) end)
  end

  def get_best_score(memo, finish) do
    [:l, :r, :u, :d]
    |> Enum.map(&Map.get(memo, {finish, &1}))
    |> Enum.filter(&(&1 != nil))
    |> Enum.min(fn -> nil end)
  end

  def is_valid_turn(:l, :r), do: false
  def is_valid_turn(:r, :l), do: false
  def is_valid_turn(:u, :d), do: false
  def is_valid_turn(:d, :u), do: false
  def is_valid_turn(_, _), do: true

  def step_cost(:l, :l), do: 1
  def step_cost(:r, :r), do: 1
  def step_cost(:u, :u), do: 1
  def step_cost(:d, :d), do: 1
  def step_cost(_, _), do: 1001

  # --------------------------------- Parsing -------------------------------- #

  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {{i, j}, get_cell_empty(c)} end)
    end)
    |> Enum.into(%{})
  end

  defp get_cell_empty("."), do: true
  defp get_cell_empty("S"), do: true
  defp get_cell_empty("E"), do: true
  defp get_cell_empty("#"), do: false

  def find_pos(lines, char) do
    {line, i} =
      lines
      |> Enum.with_index()
      |> Enum.find(fn {line, _} -> String.contains?(line, char) end)

    {_, j} =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.find(fn {c, _} -> c == char end)

    {i, j}
  end
end
