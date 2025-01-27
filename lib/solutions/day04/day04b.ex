import Solutions.Day04.Common

# Very similar to the first part. Instead of the X's we now find all A's in the
# grid, and check the two sets of diagonally adjecent cells; if these both contain
# either ["M", "S"] or ["S", "M"], we increase the total count.

defmodule Solutions.Day04.PartB do
  @diagonals_a [{-1, -1}, {1, 1}]
  @diagonals_b [{1, -1}, {-1, 1}]

  def solve(lines) do
    count(parse_grid(lines))
  end

  defp count(grid) do
    grid
    |> Enum.filter(fn {_, v} -> v == "A" end)
    |> Enum.count(fn {k, _} -> is_xmas(grid, k) end)
  end

  defp is_xmas(grid, apos) do
    is_valid(get_diagonals(grid, apos, @diagonals_a)) and
      is_valid(get_diagonals(grid, apos, @diagonals_b))
  end

  defp get_diagonals(grid, {arow, acol}, offsets) do
    offsets
    |> Enum.map(fn {orow, ocol} -> {arow + orow, acol + ocol} end)
    |> Enum.map(fn pos -> Map.get(grid, pos, "") end)
  end

  defp is_valid(["M", "S"]), do: true
  defp is_valid(["S", "M"]), do: true
  defp is_valid(_), do: false
end
