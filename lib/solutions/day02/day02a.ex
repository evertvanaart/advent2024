import Solutions.Day02.Common

# After parsing the input list for each line, compute the difference between
# each consecutive pair (using Enum.chunk_every/4 to step through all pairs);
# then, check whether 1) the absolute values of these differences are all three
# or lower, and 2) either all differences are positive, or all differences are
# negative (and not zero). Count the number of lines for which both are true.

defmodule Solutions.Day02.PartA do
  def solve(lines) do
    lines
    |> Stream.map(&parse_line/1)
    |> Stream.map(&compute_diffs/1)
    |> Enum.count(&is_safe_diffs/1)
  end
end
