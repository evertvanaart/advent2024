import Solutions.Day11.Common

# This is a staightforward recursive function. If we define f(v, n) as the
# number of stones that a stone of value v will evolve into after n steps,
# we can express this recursively. For example, for starting value 0:
#
#   f(   0, n  )
# = f(   1, n-1)
# = f(2024, n-2)
# = f(  20, n-3) + f(24, n-3)
# = f(   2, n-4) + f( 0, n-4) + f(2, n-4) + f(4, n-4)
#
# ...and so on, with the exit condition of f(v, 0) = 1 (i.e. after zero steps,
# one stone will always be one stone, regardless of its value). We use a cond
# block to implement the three rules of this recursive function in order, and
# then execute it for all starting values, using initial n = 25.
#
# This naive approach is still fairly fast; processing all starting values
# synchronously takes around 14 milliseconds, and using an async stream for
# basic parallellism reduces this to less than four milliseconds.

defmodule Solutions.Day11.PartA do
  def solve(lines) do
    values = String.split(hd(lines)) |> Enum.map(&String.to_integer/1)

    values
    |> Task.async_stream(fn v -> f(v, 25) end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp f(_, 0), do: 1

  defp f(v, n) do
    cond do
      v == 0 ->
        f(1, n - 1)

      is_even_digits(v) ->
        {left, right} = split(v)
        f(left, n - 1) + f(right, n - 1)

      true ->
        f(v * 2024, n - 1)
    end
  end
end
