import Solutions.Day18.Common

# We first parse the grid and place the specified number of blocks (using
# a set to track block positions), and we then use a simple breadth-first
# search to find the length of the shortest path. We maintain a queue (or
# actually a set) of active positions, and another set of previously visited
# positions. At every step, we return the step number if any of the positions
# in the queue is the target position; if not, we remove positions that are
# not in the grid OR have been blocked OR were visited in previous steps.
# We then get all neighbors of the remaining queue positions, and merge
# these into a set to create the queue of the next step.

defmodule Solutions.Day18.PartA do
  @start {0, 0}
  @target get_target()
  @limit get_limit()

  def solve(lines) do
    blocks =
      lines
      |> Enum.take(@limit)
      |> Enum.map(&parse_line/1)
      |> Enum.into(MapSet.new())

    queue = MapSet.new([@start])
    visited = MapSet.new()

    find_shortest_path(blocks, queue, visited, 0)
  end

  defp find_shortest_path(blocks, queue, visited, step) do
    cond do
      @target in queue ->
        step

      true ->
        valid_queue =
          queue
          |> Enum.filter(&in_grid/1)
          |> Enum.reject(&MapSet.member?(blocks, &1))
          |> Enum.reject(&MapSet.member?(visited, &1))

        new_queue =
          valid_queue
          |> Enum.flat_map(&get_neighbors/1)
          |> Enum.into(MapSet.new())

        new_visited = MapSet.union(visited, queue)

        find_shortest_path(blocks, new_queue, new_visited, step + 1)
    end
  end
end
