import Solutions.Day11.Common

# Having participated in AoC for a couple of years now, I could see this second
# part coming from a mile away, but it still took some time to solve. The naive
# solution of the first part is obviously no longer viable – it ran for more
# than 90 minutes without producing an answer – so we need some optimization.
#
# We can use memoization to skip repeated calculations, using the observation
# that the numbers on the stones show a lot of duplicates after the first couple
# of steps; especially single-digit numbers show up repeatedly due to the split-
# ting rule. To this end, we extend the recursive function with a memo parameter,
# which is a map of tuples {v, n} to the result of f(v, n). If the current values
# of v and n are already in this map, we can immediately return the corresponding
# value. If not, we compute the recursive value as we did in the first part, and
# then add it to the memoization map.
#
# Since collections in Elixir are immutable, we need to return the modified memo
# map from the recursive function. We also need to make sure that, when splitting
# a number, the map returned by the left branch is used as input for the right
# branch, otherwise the right branch won't be able to use the memoized values
# of the left branch. Similarly, we use a reduce function at the top level to
# pass an accumulator map between the starting values. Once we've processed all
# starting values, we get the final count for each starting value v by getting the
# value of {v, 75} from this accumulator map. We could've also used an async stream
# for the starting values like in the first part, but this would mean we cannot use
# the accumulated memoized map (i.e. we'd have to create a new memo map for each
# starting value), and this is actually slightly slower.

defmodule Solutions.Day11.PartB do
  def solve(lines) do
    values = String.split(hd(lines)) |> Enum.map(&String.to_integer/1)
    memo = Enum.reduce(values, %{}, fn v, memo -> process(v, memo) end)
    values |> Enum.map(&Map.get(memo, {&1, 75})) |> Enum.sum()
  end

  defp process(v, memo) do
    {_, new_memo} = f(v, 75, memo)
    new_memo
  end

  defp f(_, 0, memo), do: {1, memo}

  defp f(v, n, memo) do
    cond do
      (memo_value = Map.get(memo, {v, n})) != nil ->
        {memo_value, memo}

      v == 0 ->
        {value, new_memo} = f(1, n - 1, memo)
        new_memo = Map.put(new_memo, {v, n}, value)
        {value, new_memo}

      is_even_digits(v) ->
        {left, right} = split(v)
        {value_left, new_memo} = f(left, n - 1, memo)
        {value_right, new_memo} = f(right, n - 1, new_memo)
        new_memo = Map.put(new_memo, {v, n}, value_left + value_right)
        {value_left + value_right, new_memo}

      true ->
        {value, new_memo} = f(v * 2024, n - 1, memo)
        new_memo = Map.put(new_memo, {v, n}, value)
        {value, new_memo}
    end
  end
end
