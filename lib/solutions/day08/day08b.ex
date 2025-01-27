import Solutions.Day08.Common

# After obtaining the groups, we now create a list of antinode generators,
# simple linear functions that can create an infinite sequence of antinodes,
# one for each step number N. Each pair of positions of the same frequency
# results in two such generators, one starting at A and moving away from B,
# and one starting at B and moving away from A. In practice, a generator
# consists only of a starting position and a step vector.
#
# Once we've got all generators, we run them through a reduce operation,
# using an ever-growing set of antinode positions as the accumulator. For
# each generator, we iterate through values of the step number N starting
# from zero, computing the antinode position for each N (start + N * step)
# until we leave the grid; the resulting list of antinode positions is added
# to the accumulator set, and the final size of this set gives us our answer.
# In order to avoid an infinite sequence for N, we cap its range at the
# maximum of the row count and column count, since we can never have
# more steps inside the grid than this maximum.

defmodule Solutions.Day08.PartB do
  def solve(lines) do
    {nr_rows, nr_cols} = get_dimensions(lines)
    max_steps = max(nr_rows, nr_cols)
    dimensions = {nr_rows, nr_cols}

    groups = parse_groups(lines)

    groups
    |> Enum.map(&get_generators/1)
    |> List.flatten()
    |> Enum.reduce(MapSet.new(), fn {start, step}, antinodes ->
      MapSet.union(
        antinodes,
        0..max_steps
        |> Stream.map(fn n -> calculate_position(start, step, n) end)
        |> Stream.take_while(fn pos -> is_in_grid(pos, dimensions) end)
        |> Enum.into(MapSet.new())
      )
    end)
    |> MapSet.size()
  end

  defp calculate_position({start_i, start_j}, {step_i, step_j}, n),
    do: {start_i + n * step_i, start_j + n * step_j}

  defp get_generators(positions) do
    pairs = get_all_pairs(positions)
    generators_a = pairs |> Enum.map(fn {a, b} -> get_generator(a, b) end)
    generators_b = pairs |> Enum.map(fn {a, b} -> get_generator(b, a) end)
    generators_a ++ generators_b
  end

  defp get_generator({ia, ja}, {ib, jb}), do: {{ia, ja}, {ia - ib, ja - jb}}
end
