import Solutions.Day07.Common

# A straightforward recursive solution. At every step, we try both operators,
# and recurse to the next value. We can break early from this recursion if the
# current value exceeds the target value (since all input values are positive,
# both operators can only ever increase the total). To make maximum use of this
# early exit strategy, we check the multiplication operator before we check the
# addition operator, since repeat multiplications are more likely to cause the
# current value to exceed the target.

defmodule Solutions.Day07.PartA do
  def solve(lines) do
    lines
    |> Enum.map(&parse/1)
    |> Enum.filter(fn {v, [hd | tl]} -> is_valid(hd, tl, v) end)
    |> Enum.map(fn {v, _} -> v end)
    |> Enum.sum()
  end

  defp is_valid(value, [], target), do: value == target
  defp is_valid(value, _, target) when value > target, do: false

  defp is_valid(value, [head | tail], target) do
    is_valid(value * head, tail, target) or
      is_valid(value + head, tail, target)
  end
end
