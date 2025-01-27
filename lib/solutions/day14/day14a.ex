import Solutions.Day14.Common

# We do not need to simulate each step; since robots loop around and do not
# affect each other, we can simply multiply the step vector by the number of
# steps, add that to the starting position, and take the modulo to clip it to
# target area. At the start, we change all negative speeds to their positive
# equivalent, simply so that we do not need to bother with modulos of negative
# numbers. After computing the final positions of all robots, we find their
# quadrants as decribed, rejecting any that are not in any quadrant, and
# multiply the frequencies of each quadrant.

defmodule Solutions.Day14.PartA do
  # for sample
  # @rows 7
  # @cols 11

  # for input
  @rows 103
  @cols 101

  # step count
  @steps 100

  def solve(lines) do
    mid_row = div(@rows, 2)
    mid_col = div(@cols, 2)

    lines
    |> Enum.map(&parse_line(&1, {@rows, @cols}))
    |> Enum.map(&calculate_position(&1, {@rows, @cols}, @steps))
    |> Enum.map(&compute_quadrant(&1, {mid_row, mid_col}))
    |> Enum.reject(fn quadrant -> quadrant == nil end)
    |> Enum.frequencies()
    |> Enum.map(fn {_, l} -> l end)
    |> Enum.product()
  end

  defp compute_quadrant({x, y}, {mid_row, mid_col}) do
    cond do
      x < mid_col and y < mid_row -> 0
      x > mid_col and y < mid_row -> 1
      x < mid_col and y > mid_row -> 2
      x > mid_col and y > mid_row -> 3
      true -> nil
    end
  end
end
