import Solutions.Day19.Common

# Very similar in both approach and runtime. The main change is that the value
# of the memoization map is now an integer counting the number of valid confi-
# gurations for each remaining pattern length; if we encounter the same length
# in a future step, we can immediately return the memoized count. At the end
# of the recursion step, we sum these counts for all branches (i.e. for all
# valid towels), and insert this sum into the memoization map.

defmodule Solutions.Day19.PartB do
  def solve(lines) do
    {towels, patterns} = parse(lines)

    get_pattern_chunks(patterns)
    |> Task.async_stream(&solve_chunk(towels, &1))
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp solve_chunk(towels, patterns) do
    Enum.map(patterns, fn pattern ->
      length = String.length(pattern)
      memo = Map.new()

      {result, _} = count_options(pattern, length, towels, memo)

      result
    end)
    |> Enum.sum()
  end

  defp count_options(_, 0, _, memo), do: {1, memo}

  defp count_options(pattern, length, towels, memo) do
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
            count_options(suffix, length - tlength, towels, acc)

          true ->
            {0, acc}
        end
      end)

    result = Enum.sum(results)
    new_memo = Map.put(new_memo, length, result)

    {result, new_memo}
  end
end
