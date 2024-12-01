import Solutions.Day01.Common

# After parsing the two lists like we did in the first part, we can easily obtain a
# frequencies map – i.e., values to how often a value appears in a list – using the
# Enum.frequencies() function. We then simply iterate over the pairs of the left-hand
# frequency map, and multiply the left-hand frequency by the right-hand frequency (or
# zero) and by the actual value. Taking the sum of these products gives the answer.

defmodule Solutions.Day01.PartB do
  def solve(lines) do
    {left, right} = parse_lines(lines)

    lfreqs = Enum.frequencies(left)
    rfreqs = Enum.frequencies(right)

    lfreqs |> Stream.map(fn {v, f} -> v * f * Map.get(rfreqs, v, 0) end) |> Enum.sum()
  end
end
