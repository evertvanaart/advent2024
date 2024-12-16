import Solutions.Day14.Common

# I really did not enjoy this one.
#
# I did the thing you're apparently supposed to do – generate a whole bunch of
# steps, then spend half an hour scrolling though them looking for a tree – but
# I either didn't generate enough steps or scrolled right past the actual image.
# I ended up looking up what the image is supposed to look like on one of the
# various AoC blogs, then wrote a simple function that draws the grid when we
# find the top of the frame, which allowed me at least get my star.
#
# I checked out some other approaches, and even the "smarter" solutions all
# make some assumptions about what the image is supposed to look like, such as
# looking for a frame, or looking for clusters of robots, or checking heuristics
# like entropy or the safety score from the first part. However, without any hints
# regarding what the image should look like, it all still comes down to guesses
# and visual inspection of likely frames, and I find that deeply unsatisfying.
# Even some relatively minor hints like "the image will have a frame" or the
# "the image will be off-center" would have made this question much better.

# I saw some comments from people who really loved this one, and good for them,
# but a strong thumbs down from me personally. Marking the runtime for this as
# "N/A" since it cannot be fully solved programmatically.

defmodule Solutions.Day14.PartB do
  @target "###############################"

  @max_steps 100_000_000

  @rows 103
  @cols 101

  def solve(lines) do
    robots = Enum.map(lines, &parse_line(&1, {@rows, @cols}))

    0..@max_steps
    |> Enum.each(fn steps ->
      positions = Enum.map(robots, &calculate_position(&1, {@rows, @cols}, steps))
      draw(steps, Enum.into(positions, MapSet.new()), {@rows, @cols})
    end)
  end

  defp draw(steps, positions, {rows, cols}) do
    lines =
      0..(rows - 1)
      |> Enum.map(fn y ->
        0..(cols - 1)
        |> Enum.map(fn x -> get_char({x, y}, positions) end)
        |> Enum.join()
      end)

    if Enum.any?(lines, fn line -> String.contains?(line, @target) end) do
      IO.puts("--- Step #{steps} ---")
      Enum.each(lines, &IO.puts/1)
      IO.puts("")
    end
  end

  defp get_char(p, positions) do
    if MapSet.member?(positions, p), do: "#", else: "."
  end
end
