import Solutions.Day01.Common

# An easy first day, and the kind of problem that can be solved very elegantly in
# Elixir. We first parse the lines into two separate lists – Enum.unzip() is very
# useful here – then sort them and zip them back up, this time computing the sum
# of the absolute difference of each pair. At around six milliseconds it isn't
# particularly fast, but based on some superficial profiling most of this time
# comes from the String.split() call, which we can't easily avoid.

defmodule Solutions.Day01.PartA do
  def solve(lines) do
    {left, right} = parse_lines(lines)

    Stream.zip(Enum.sort(left), Enum.sort(right))
    |> Stream.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end
end
