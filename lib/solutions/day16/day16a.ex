import Solutions.Day16.Common

# We use a breadth-first recursive approach. In each step, we have a queue of
# path positions, each consisting of a current position, direction, and cost.
# These path positions will usually be located at the start of a non-branching
# path, i.e. in a position orthogonal to an intersection cell (or the starting
# position), and facing away from that cell; the queue can also contain path
# positions that have reached the finish position.
#
# For each of these queue entries, we then trace a path to the next intersection
# by recursively moving the position along the grid, updating the direction and
# cost as we move. The path is at no point allowed to make a U-turn, since there
# is no scenario in which doing so would result in an optimal score. If at any
# point there is no valid next position, we've reached a dead end, and this queue
# item can be discarded. Otherwise, we keep going until we reach an intersection,
# i.e. a cell with more than one valid next position. We then create a new queue
# item for each valid branch at this intersection.
#
# After tracing paths for all current queue items, thus obtaining a list of new
# queue items, we reject all items that are either 1) worse than the best score
# at this position and direction in the current new queue, OR 2) worse than the
# best score at this position and direction seen in previous steps, using a memo-
# ization map, OR 3) worse than the current best score at the finish line, if any.
# After updating the memoization map with the new best scores from the remaining
# items, we recurse to the next step, and we continue until the queue is empty.
#
# When this recursion has finished, we are left with a memoization map containing
# the best scores at each position and direction. At this point, all we need to do
# is get the scores at the finish position, and compute their minimum value.

defmodule Solutions.Day16.PartA do
  def solve(lines) do
    grid = parse_grid(lines)
    start = find_pos(lines, "S")
    finish = find_pos(lines, "E")

    initial_queue =
      get_open_neighbors(grid, start)
      |> Enum.map(fn {pos, dir} -> {pos, dir, step_cost(:r, dir)} end)

    final_memo = recurse(grid, initial_queue, finish, %{})

    get_best_score(final_memo, finish)
  end

  # ------------------------- Main recursive function ------------------------ #

  defp recurse(_, [], _, memo), do: memo

  defp recurse(grid, queue, finish, memo) do
    # trace paths to the next intersection or the finish
    new_queue =
      Enum.flat_map(queue, fn {pos, dir, cost} ->
        trace_path(grid, finish, pos, dir, cost)
      end)

    best_score = get_best_score(memo, finish)

    # for each combination of position and direction in the new queue,
    # take the one with the lowest cost, and subsequently reject it if
    # it is larger than the memoized cost (if any); also reject all
    # paths that have a score greater than the best overall score

    new_queue =
      new_queue
      |> Enum.group_by(fn {pos, dir, _} -> {pos, dir} end)
      |> Enum.map(fn {_, v} -> Enum.min_by(v, fn {_, _, c} -> c end) end)
      |> Enum.reject(fn {pos, dir, cost} -> Map.get(memo, {pos, dir}) <= cost end)
      |> Enum.reject(fn {_, _, cost} -> cost >= best_score end)

    # update the memoization map with the new optimal values
    new_memo =
      Enum.reduce(new_queue, memo, fn {pos, dir, cost}, acc ->
        Map.put(acc, {pos, dir}, cost)
      end)

    # remove all finish positions from the queue
    new_queue = Enum.reject(new_queue, fn {pos, _, _} -> pos == finish end)

    # recurse using the new queue
    recurse(grid, new_queue, finish, new_memo)
  end

  # ------------------------------ Tracing paths ----------------------------- #

  defp trace_path(_, finish, pos, dir, cost) when pos == finish, do: [{pos, dir, cost}]

  defp trace_path(grid, finish, pos, dir, cost) do
    # get all neighboring positions (with their directions) that are not a
    # wall, and that can be reached with a turn of zero or ninety degrees
    valid_neighbors =
      get_open_neighbors(grid, pos)
      |> Enum.filter(fn {_, ndir} -> is_valid_turn(ndir, dir) end)

    case length(valid_neighbors) do
      # no such neighbor means a dead end
      0 ->
        []

      1 ->
        # one neighbor, continue following the path
        {new_pos, new_dir} = hd(valid_neighbors)
        new_cost = cost + step_cost(dir, new_dir)
        trace_path(grid, finish, new_pos, new_dir, new_cost)

      _ ->
        # more than one neighbor means we've reached a new intersection;
        # create new queue items at the starts of each of the new paths

        valid_neighbors
        |> Enum.map(fn {new_pos, new_dir} ->
          new_cost = cost + step_cost(dir, new_dir)
          {new_pos, new_dir, new_cost}
        end)
    end
  end
end
