import Solutions.Day06.Common

# We first parse the grid to a map, with coordinate tuples mapping to
# cell types. We then use a recursive function to trace the path, at each
# step determining the next position and direction, and keeping track of
# the positions visited so far in a set. When the path leaves the grid,
# we simply return the size of this set of visited positions.

defmodule Solutions.Day06.PartA do
  def solve(lines) do
    start = find_start(lines)
    grid = parse_grid(lines)

    visited = trace_path(grid, start, :n, MapSet.new())

    MapSet.size(visited)
  end
end
