import Solutions.Day10.Common

# After parsing the grid and finding all starting positions, we execute a
# recursive function for each starting position to find all peaks that can
# be reached from that position. In each step, we check whether the current
# position is in the grid, and whether its value is equal to the expected
# value (incremented by one each step); if not, we return an empty array.
# If the value is correct, we recurse to each of the four neighbors of
# the current position, and we flatten their results into a single list;
# if we reach an expected value of nine, we've found a valid path to a
# peak, and return the current peak position.
#
# After this recursive call, we have a list of peaks that can be reached
# from the current starting position, but this list can contain duplicates
# if the same peak can be reached in more than one way from the same start.
# Since we are only interested in the number of peaks that can be reached,
# we compute the number of unique elements in this list of peaks, and take
# the sum for all starting positions to get our answer.

defmodule Solutions.Day10.PartA do
  def solve(lines) do
    grid = parse_grid(lines)
    starts = get_starts(grid)

    starts
    |> Enum.map(fn pos -> find_peaks(grid, pos, 0) end)
    |> Enum.map(fn peaks -> Enum.uniq(peaks) end)
    |> Enum.map(fn peaks -> length(peaks) end)
    |> Enum.sum()
  end
end
