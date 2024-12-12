import Solutions.Day12.Common

# After parsing the grid, we recursively try to find regions. We do so by
# iterating through all positions in the grid (in arbitrary order), keeping
# track of two accumulator values: a cost, which will in the end produce the
# final answer, and a set of fields belonging to regions that have already
# been found. If the new position is in this set, we simply skip it.
#
# For positions that are not yet in a previously found region, we use a
# recursive function to find all fields in its region. I opted for a breath-
# first approach here, where in each step we have a queue of fields to check.
# We start by removing fields from this queue that we've already assigned to
# the current region in a previous recursion step. Next, we check which of
# those fields have the same plant as the starting position, meaning they
# are in the same region. These valid fields are added to the set of region
# fields, and their neighbors become the queue for the next recursion step.
#
# Every time we encounter an invalid field (i.e., a field with a different
# plan type, or a field that is outside of the grid), the number of required
# fences is increased by one, since this represents a border from the current
# region to a different region. In practice, the number of new fences in each
# step is equal to the difference between all new fields in the queue (i.e.
# not yet part of the region) and the number of valid new fields (i.e. with
# the right plant). This means that we can count fences as we're outlining
# regions, and we do not need to e.g. reconstruct fences from regions.

defmodule Solutions.Day12.PartA do
  def solve(lines) do
    grid = parse_grid(lines)

    {cost, _} =
      grid
      |> Enum.reduce({0, MapSet.new()}, fn {pos, _}, {cost, done} ->
        case MapSet.member?(done, pos) do
          true ->
            {cost, done}

          false ->
            {new_cost, new_region} = find_region(grid, pos)
            {cost + new_cost, MapSet.union(done, new_region)}
        end
      end)

    cost
  end

  defp find_region(grid, pos) do
    {fields, fences} = recurse([pos], grid, Map.get(grid, pos), MapSet.new(), 0)
    {MapSet.size(fields) * fences, fields}
  end

  defp recurse([], _, _, fields, fences), do: {fields, fences}

  defp recurse(queue, grid, plant, fields, fences) do
    new_fields = Enum.reject(queue, &MapSet.member?(fields, &1))
    valid_fields = Enum.filter(new_fields, &(Map.get(grid, &1) == plant))
    new_fences = length(new_fields) - length(valid_fields)

    valid_fields_set = Enum.into(valid_fields, MapSet.new())
    next_fields = MapSet.union(fields, valid_fields_set)
    next_queue = get_neighbors(valid_fields_set)
    next_fences = fences + new_fences

    recurse(next_queue, grid, plant, next_fields, next_fences)
  end
end
