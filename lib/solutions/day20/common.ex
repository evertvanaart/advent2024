defmodule Solutions.Day20.Common do
  @neighbors [
    {1, 0},
    {0, 1},
    {-1, 0},
    {0, -1}
  ]

  # ------------------------- Find shortest distances ------------------------ #

  def find_shortest(walls, position, cost, memo) do
    cond do
      Map.get(walls, position, true) ->
        memo

      Map.get(memo, position) < cost ->
        memo

      true ->
        new_memo = Map.put(memo, position, cost)

        get_neighbors(position)
        |> Enum.reduce(new_memo, fn neighbor, acc ->
          find_shortest(walls, neighbor, cost + 1, acc)
        end)
    end
  end

  # ---------------------------- Utility functions --------------------------- #

  def get_neighbors(p, d \\ 1), do: Enum.map(@neighbors, &add_offset(p, &1, d))
  def add_offset({px, py}, {ox, oy}, d \\ 1), do: {px + d * ox, py + d * oy}

  # --------------------------------- Parsing -------------------------------- #

  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, j} ->
        {{i, j}, is_wall(c)}
      end)
    end)
    |> Enum.into(%{})
  end

  def find_position(lines, char) do
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

  defp is_wall("#"), do: true
  defp is_wall(_), do: false
end
