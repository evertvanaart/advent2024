import Solutions.Day01.Common

# After parsing the two lists like we did in the first part, we can easily obtain a
# frequencies map – i.e., values to how often a value appears in a list – using the
# Enum.frequencies/1 function. We know that only values that appear in both lists
# contribute to the final sum, which corresponds to the intersection of these two
# frequency maps. Elixir's Map.intersect/3 allows us to pass a function for resolving
# conflicts, and we use this function to multiply the frequencies in the left and right
# lists. Then, all we need to do is iterate over all key-value pairs in the intersected
# map, compute the products of the key and the value, and sum up these products; we can
# use Enum.reduce/3 to do both operations in a single pass.

defmodule Solutions.Day01.PartB do
  def solve(lines) do
    {left, right} = parse_lines(lines)

    lfreqs = Enum.frequencies(left)
    rfreqs = Enum.frequencies(right)

    Map.intersect(lfreqs, rfreqs, fn _, l, r -> l * r end)
    |> Enum.reduce(0, fn {k, v}, acc -> acc + k * v end)
  end
end
