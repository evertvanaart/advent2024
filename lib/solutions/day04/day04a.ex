import Solutions.Day04.Common

# We first parse the grid to a map, with a tuple of row index and column index
# mapping to the character at that index. We then find all X's in the grid, and
# for each X check the three cells in all eight directions; if the characters
# in those cells spell "MAS", we increase the total count.
#
# In other languages I would use a one-dimensional array instead of a map,
# since this is typically faster. However, Elixir does not have an array-like
# data structure with constant index-based access times (List uses linked lists,
# so accessing an index is an O(N) operation), so I opted to stick with the map;
# this is still fairly fast, and it's easier to deal with off-grid reads.

defmodule Solutions.Day04.PartA do
  @offsets_b [{1, 0}, {2, 0}, {3, 0}]
  @offsets_r [{0, 1}, {0, 2}, {0, 3}]
  @offsets_t [{-1, 0}, {-2, 0}, {-3, 0}]
  @offsets_l [{0, -1}, {0, -2}, {0, -3}]
  @offsets_br [{1, 1}, {2, 2}, {3, 3}]
  @offsets_bl [{1, -1}, {2, -2}, {3, -3}]
  @offsets_tr [{-1, 1}, {-2, 2}, {-3, 3}]
  @offsets_tl [{-1, -1}, {-2, -2}, {-3, -3}]

  @all_offsets [
    @offsets_b,
    @offsets_r,
    @offsets_t,
    @offsets_l,
    @offsets_br,
    @offsets_bl,
    @offsets_tr,
    @offsets_tl
  ]

  def solve(lines) do
    count(parse_grid(lines))
  end

  defp count(grid) do
    grid
    |> Enum.filter(fn {_, char} -> char == "X" end)
    |> Enum.map(fn {pos, _} -> count_at(grid, pos) end)
    |> Enum.sum()
  end

  defp count_at(grid, {xrow, xcol}) do
    @all_offsets
    |> Enum.count(fn offsets ->
      Enum.zip(offsets, ["M", "A", "S"])
      |> Enum.map(fn {{orow, ocol}, char} -> {{xrow + orow, xcol + ocol}, char} end)
      |> Enum.all?(fn {pos, char} -> Map.get(grid, pos) == char end)
    end)
  end
end
