import Solutions.Day12.Common

# We cannot easily keep track of fences – let alone sections of fences – while
# we're outline the regions, so instead we find the region, and then calculate
# the number of segments in the fences surrounding that region.
#
# For each of the four directions, we find region fields that have a fence in
# that direction, i.e. the neighboring field in that direction is not part of
# the region's set. For each of the four resulting lists of fence fields, we
# then compute the number of fence sections. We first group the fence fields
# by row (for horizontal segments) or column (for vertical segments), and in
# each row or column check the column or row indices for continuous groups,
# i.e. slices in which subsequent indices all have a difference of one.
#
# Computing the number of fence sections per direction and then summing the
# four results gives us the total number of fence sections, and this allows
# us to compute the total cost for each section. This is already fairly fast,
# although we could probably speed it up by calling calculate_cost/1 async.

defmodule Solutions.Day12.PartB do
  def solve(lines) do
    grid = parse_grid(lines)

    {cost, _} =
      grid
      |> Enum.reduce({0, MapSet.new()}, fn {pos, _}, {cost, done} ->
        case MapSet.member?(done, pos) do
          true ->
            {cost, done}

          false ->
            new_region = find_region(grid, pos)
            new_cost = calculate_cost(new_region)
            {cost + new_cost, MapSet.union(done, new_region)}
        end
      end)

    cost
  end

  # ----------------------------- Finding regions ---------------------------- #

  defp find_region(grid, pos) do
    recurse([pos], grid, Map.get(grid, pos), MapSet.new())
  end

  defp recurse([], _, _, fields), do: fields

  defp recurse(queue, grid, plant, fields) do
    new_fields = Enum.reject(queue, &MapSet.member?(fields, &1))
    valid_fields = Enum.filter(new_fields, &(Map.get(grid, &1) == plant))

    valid_fields_set = Enum.into(valid_fields, MapSet.new())
    next_fields = MapSet.union(fields, valid_fields_set)
    next_queue = get_neighbors(valid_fields_set)

    recurse(next_queue, grid, plant, next_fields)
  end

  # ------------------------ Calculating region costs ------------------------ #

  defp calculate_cost(region) do
    fences_d = find_fences(region, {1, 0})
    fences_r = find_fences(region, {0, 1})
    fences_u = find_fences(region, {-1, 0})
    fences_l = find_fences(region, {0, -1})

    groups_d = count_sections_h(fences_d)
    groups_r = count_sections_v(fences_r)
    groups_u = count_sections_h(fences_u)
    groups_l = count_sections_v(fences_l)

    fence_segments = groups_d + groups_r + groups_u + groups_l
    fence_segments * MapSet.size(region)
  end

  defp find_fences(region, offset) do
    region
    |> Enum.map(fn pos -> {pos, add_offset(pos, offset)} end)
    |> Enum.reject(fn {_, neighbor} -> MapSet.member?(region, neighbor) end)
    |> Enum.map(fn {pos, _} -> pos end)
  end

  defp count_sections_h(fences) do
    fences
    |> Enum.group_by(fn {i, _} -> i end, fn {_, j} -> j end)
    |> Enum.map(fn {_, js} -> count_groups(js) end)
    |> Enum.sum()
  end

  defp count_sections_v(fences) do
    fences
    |> Enum.group_by(fn {_, j} -> j end, fn {i, _} -> i end)
    |> Enum.map(fn {_, is} -> count_groups(is) end)
    |> Enum.sum()
  end

  defp count_groups(values) do
    1 +
      (values
       |> Enum.sort()
       |> Enum.chunk_every(2, 1, :discard)
       |> Enum.count(fn [l, r] -> r != l + 1 end))
  end
end
