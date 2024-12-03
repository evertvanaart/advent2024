import Solutions.Day03.Common

# We first split the string at all occurrences of "do()"; the result is a list
# of substrings that are all enabled at the start. Next, we split each substring
# once at the first occurence of "don't()" (if any) and discard everything after
# this "don't()", leaving us with only the enabled parts of the input. We then
# use the solution of the first part on each enabled string.
#
# The only other thing to note is that the input consists of six separate lines,
# and I initially processed each line separately, i.e. re-enabling multiplication
# instructions at the start of each line, which is incorrect. Joining these six
# lines into a single string fixed this issue.

defmodule Solutions.Day03.PartB do
  def solve(lines) do
    Enum.join(lines)
    |> String.split("do()")
    |> Enum.map(fn s -> String.split(s, "don't()", parts: 2) end)
    |> Enum.map(fn [s | _] -> process_mul(s) end)
    |> Enum.sum()
  end
end
