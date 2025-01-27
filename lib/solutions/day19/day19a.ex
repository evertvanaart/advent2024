import Solutions.Day19.Common

# This is an obvious candidate for recursion. In each step, we check which
# towels are prefixes of the remaining pattern string, and for each matching
# towel we recurse on the tail of that pattern string, i.e. the input string
# minus the towel prefix. If the length of the remaining string reaches zero,
# we've found a valid configuration of towels.
#
# There are some small optimizations we can do here (getting the string length
# is O(n) in Elixir, so computing string lengths in advance is slightly faster),
# but the main optimization is the introduction of a memoization map, which maps
# the remaining string length to the previously computed result for that length
# (true or false, depending on whether a full match was found). This allows us
# to skip a large number of redundant calculations, i.e. the result of the last
# X characters of the pattern is always going to be the same, regardless of the
# towel configuration of the preceding Y characters.
#
# As a minor additional optimization, we get slightly better results if we check
# the towels in order from shortest to longest, since this will increase the hit
# rate of the memoization map. We also use an asynchronous stream to process
# chunks of patterns in parallel (see Day 7b for comments on optimal chunk
# size). Combined, these optimizations allow this to run in less than 100ms.

defmodule Solutions.Day19.PartA do
  def solve(lines) do
    {towels, patterns} = parse(lines)

    get_pattern_chunks(patterns)
    |> Task.async_stream(&solve_chunk(towels, &1))
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp solve_chunk(towels, patterns) do
    Enum.count(patterns, fn pattern ->
      length = String.length(pattern)
      memo = Map.new()

      {result, _} = is_possible(pattern, length, towels, memo)

      result
    end)
  end

  defp is_possible(_, 0, _, memo), do: {true, memo}

  defp is_possible(pattern, length, towels, memo) do
    case Map.get(memo, length) do
      nil -> recurse(pattern, length, towels, memo)
      memo_value -> {memo_value, memo}
    end
  end

  defp recurse(pattern, length, towels, memo) do
    {results, new_memo} =
      towels
      |> Enum.map_reduce(memo, fn {towel, tlength}, acc ->
        cond do
          String.starts_with?(pattern, towel) ->
            suffix = String.replace_prefix(pattern, towel, "")
            is_possible(suffix, length - tlength, towels, acc)

          true ->
            {false, acc}
        end
      end)

    result = Enum.any?(results)
    new_memo = Map.put(new_memo, length, result)

    {result, new_memo}
  end
end
