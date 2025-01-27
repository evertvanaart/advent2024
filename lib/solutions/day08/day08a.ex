import Solutions.Day08.Common

# We first parse the input grid into a list of lists, with each sub-list
# containing all positions for one frequency. For each of those sub-lists,
# we get all pairs, i.e. all unique combinations of two elements in the
# list; Elixir does not appear to have a function for this, but we can
# easily create one ourselves using recursion, see get_all_pairs/1.
#
# For each pair of positions of the same frequency, we then simply
# calculate one antinode by subtracting the difference between positions
# A and B from the position of A; swapping A and B gives us the second
# antinode. Once we've got all antinodes, we remove all positions that
# are not on the grid, and convert the remainder into a set to remove
# duplicates; the size of the resulting set is our answer.

defmodule Solutions.Day08.PartA do
  def solve(lines) do
    dimensions = get_dimensions(lines)
    groups = parse_groups(lines)

    antinodes = Enum.map(groups, &get_antinodes/1)

    List.flatten(antinodes)
    |> Enum.filter(&is_in_grid(&1, dimensions))
    |> Enum.into(MapSet.new())
    |> MapSet.size()
  end

  defp get_antinodes(positions) do
    pairs = get_all_pairs(positions)
    antinodes_a = pairs |> Enum.map(fn {a, b} -> get_antinode(a, b) end)
    antinodes_b = pairs |> Enum.map(fn {a, b} -> get_antinode(b, a) end)
    antinodes_a ++ antinodes_b
  end

  defp get_antinode({ia, ja}, {ib, jb}), do: {ia - (ib - ia), ja - (jb - ja)}
end
