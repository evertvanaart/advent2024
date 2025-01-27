import Solutions.Day18.Common

# We now use a depth-first approach to path finding, in which we simply try
# to find any path from start to finish; if such a path exists, we return a
# set containing all positions visited along the way. The order of the neigh-
# boring cell offsets is important here, since we typically want to try the
# neighbors to the right and down before we try up and left.
#
# After finding an initial path – which will simply hug the top and right
# edges of the area – we then start placing blocks. In each step, we check
# if the new block is on the current path. If so, we compute a new path, and
# return the new block position if no such path exists. If not, we keep using
# the current path for the next block. In this way, we ensure that we do not
# unnecessarily recompute paths, i.e. we only need to run the path-finding
# function if the previous path has been blocked. How effective this is in
# practice of course depends on the block positions, but with our input we
# only need to recompute a new path for roughly 3% of all blocks.

defmodule Solutions.Day18.PartB do
  @start {0, 0}
  @target get_target()

  def solve(lines) do
    remaining_blocks = Enum.map(lines, &parse_line/1)

    blocks = MapSet.new()

    initial_path = find_path(blocks, @start, MapSet.new())
    {x, y} = find_obstacle(blocks, remaining_blocks, initial_path)

    "#{x},#{y}"
  end

  # ------------------------- Checking for obstacles ------------------------- #

  defp find_obstacle(blocks, [next_block | tail], path) do
    new_blocks = MapSet.put(blocks, next_block)

    case next_block in path do
      false ->
        # current path is not affected, continue with next block
        find_obstacle(new_blocks, tail, path)

      true ->
        # current path is now blocked, try to find a new path
        new_path = find_path(new_blocks, @start, MapSet.new())

        case new_path do
          nil -> next_block
          _ -> find_obstacle(new_blocks, tail, new_path)
        end
    end
  end

  # ----------------------------- Finding a path ----------------------------- #

  defp find_path(_, position, visited) when position == @target, do: visited

  defp find_path(blocks, position, visited) do
    cond do
      !in_grid(position) ->
        nil

      MapSet.member?(blocks, position) ->
        nil

      MapSet.member?(visited, position) ->
        nil

      true ->
        new_visited = MapSet.put(visited, position)

        get_neighbors(position)
        |> Stream.map(&find_path(blocks, &1, new_visited))
        |> Enum.find(&(&1 != nil))
    end
  end
end
