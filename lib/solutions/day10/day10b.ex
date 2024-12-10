import Solutions.Day10.Common

# This was probably the fastest I've solved a second part of an AoC question.
# Since the array returned by the recursive function of the first part can
# contain duplicates – one duplicate peak for each path to that peak – all
# we have to do for the second part is remove the line that eliminates these
# duplicates, thus giving us the requested number of paths to any peak from
# each starting position. I originally planned to use a set instead of a list
# during recursion, i.e. get rid of duplicate peaks as we're recursing, but
# I found that eliminating duplicates afterwards was fast enough, and by
# coincidence this approach made the second part very easy.

defmodule Solutions.Day10.PartB do
  def solve(lines) do
    grid = parse_grid(lines)
    starts = get_starts(grid)

    starts
    |> Enum.map(fn pos -> find_peaks(grid, pos, 0) end)
    |> Enum.map(fn peaks -> length(peaks) end)
    |> Enum.sum()
  end
end
