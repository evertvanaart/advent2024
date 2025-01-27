import Solutions.Day16.Common

# Very similar to the first approach. When tracing paths, we now additionally
# keep track of all visited cells in a set, and after recursively finding all
# optimal paths we compute the size of the union of all optimal path sets.
#
# The big difference is that we can now no longer reject paths with a score
# _equal to_ previous best scores, since these paths might also result in an
# optimal path in the end. However, if we keep all items in the new queue that
# have an optimal score, the number of items in the queue will explode, and
# the solution will become extremely slow.
#
# Instead, we merge optimal items into a single item. After grouping items in
# the new queue by position and direction, we reject all items that have a score
# worse than the best score, and all items with a score equal to the best score
# get merged into a single item, with a path set that contains all entries of
# the paths of all merged items. This helps keep the number of queue items in
# check, and as a result the algorithm still finishes in less than a second.

defmodule Solutions.Day16.PartB do
  def solve(lines) do
    grid = parse_grid(lines)
    start = find_pos(lines, "S")
    finish = find_pos(lines, "E")

    initial_path = MapSet.new([start])

    initial_queue =
      get_open_neighbors(grid, start)
      |> Enum.map(fn {pos, dir} -> {pos, dir, step_cost(:r, dir), initial_path} end)

    paths = recurse(grid, initial_queue, finish, %{}, [])
    min_cost = Enum.map(paths, fn {cost, _} -> cost end) |> Enum.min()
    best_paths = Enum.filter(paths, fn {cost, _} -> cost == min_cost end)

    positions =
      best_paths
      |> Enum.map(fn {_, path} -> path end)
      |> Enum.reduce(MapSet.new(), fn v, a -> MapSet.union(v, a) end)

    MapSet.size(positions) + 1
  end

  # ------------------------- Main recursive function ------------------------ #

  defp recurse(_, [], _, _, paths), do: paths

  defp recurse(grid, queue, finish, memo, paths) do
    # trace paths to the next intersection or the finish
    new_queue =
      Enum.flat_map(queue, fn {pos, dir, cost, path} ->
        trace_path(grid, finish, pos, dir, cost, path)
      end)

    best_score = get_best_score(memo, finish)

    # reject scores that are worse than the best overall score so far (if any), or
    # that are worse than the memoized best score at the current position and direc-
    # tion (if any); note, scores equal to these best scores are _not_ rejected.

    new_queue =
      new_queue
      |> Enum.reject(fn {_, _, cost, _} -> cost > best_score end)
      |> Enum.reject(fn {pos, dir, cost, _} -> Map.get(memo, {pos, dir}) < cost end)

    # for each combination of position and direction in the new queue, find all
    # entries that have the best score at that position and direction (rejecting
    # entries with a worse score), then merge them into a single entry, with a
    # path set containing all values of all merged paths

    new_queue = merge_equal_costs(new_queue)

    # update the memoization map with the new optimal values

    new_memo =
      Enum.reduce(new_queue, memo, fn {pos, dir, cost, _}, acc ->
        Map.put(acc, {pos, dir}, cost)
      end)

    # add paths that have reached the finish to the output path list (with cost)

    new_paths =
      paths ++
        (new_queue
         |> Enum.filter(fn {pos, _, _, _} -> pos == finish end)
         |> Enum.map(fn {_, _, cost, path} -> {cost, path} end))

    # remove all finish positions from the queue
    new_queue = Enum.reject(new_queue, fn {pos, _, _, _} -> pos == finish end)

    # recurse using the new queue
    recurse(grid, new_queue, finish, new_memo, new_paths)
  end

  defp merge_equal_costs(queue) do
    queue
    |> Enum.group_by(fn {pos, dir, _, _} -> {pos, dir} end)
    |> Enum.map(fn {k, v} -> {k, v, get_minimum_cost(v)} end)
    |> Enum.map(fn {k, v, min} -> {k, filter_costs(v, min), min} end)
    |> Enum.map(fn {{pos, dir}, v, cost} -> {pos, dir, cost, merge_paths(v)} end)
  end

  defp get_minimum_cost(v), do: Enum.map(v, fn {_, _, c, _} -> c end) |> Enum.min()
  defp filter_costs(v, min), do: Enum.reject(v, fn {_, _, cost, _} -> cost > min end)
  defp merge_paths(v), do: Enum.reduce(v, MapSet.new(), fn v, acc -> merge_sets(v, acc) end)
  defp merge_sets({_, _, _, path}, acc), do: MapSet.union(acc, path)

  # ------------------------------ Tracing paths ----------------------------- #

  defp trace_path(_, finish, pos, dir, cost, path) when pos == finish,
    do: [{pos, dir, cost, path}]

  defp trace_path(grid, finish, pos, dir, cost, path) do
    valid_neighbors =
      get_open_neighbors(grid, pos)
      |> Enum.filter(fn {_, ndir} -> is_valid_turn(ndir, dir) end)

    case length(valid_neighbors) do
      0 ->
        []

      1 ->
        {new_pos, new_dir} = hd(valid_neighbors)
        new_cost = cost + step_cost(dir, new_dir)
        new_path = MapSet.put(path, pos)

        trace_path(grid, finish, new_pos, new_dir, new_cost, new_path)

      _ ->
        valid_neighbors
        |> Enum.map(fn {new_pos, new_dir} ->
          new_cost = cost + step_cost(dir, new_dir)
          new_path = MapSet.put(path, pos)

          {new_pos, new_dir, new_cost, new_path}
        end)
    end
  end
end
