import Solutions.Day07.Common

# The same approach as in the first part. The addition of a third operator does
# significantly increase the runtime, from around 10 microseconds to almost half
# a second. Based on some quick tests, I found that the current operator order
# (first multiplication, then concatenation, then addition) is fastest, since
# it maximizes the probability that we can exit early from the recursive loop.
#
# To speed this up further, we use a parallel stream, processing several chunks
# of lines at the same time and summing the results of each chunk. Based on some
# quick experiments, I found that using a number of chunks roughly equal to four
# times the number of schedulers produces the fastest results. One observation
# here is that setting the "max_concurrency" option of Task.async_stream/3 to
# match this chunk count results in worse performance than leaving it at its
# default value of System.schedulers_online/0, which is somewhat unexpected.

defmodule Solutions.Day07.PartB do
  def solve(lines) do
    chunk_count = System.schedulers_online() * 4
    chunk_size = max(div(length(lines), chunk_count), 1)
    line_chunks = Enum.chunk_every(lines, chunk_size)

    line_chunks
    |> Task.async_stream(fn lines ->
      lines
      |> Enum.map(&parse/1)
      |> Enum.filter(fn {v, [hd | tl]} -> is_valid(hd, tl, v) end)
      |> Enum.map(fn {v, _} -> v end)
      |> Enum.sum()
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp is_valid(value, [], target), do: value == target
  defp is_valid(value, _, target) when value > target, do: false

  defp is_valid(value, [head | tail], target) do
    is_valid(value * head, tail, target) or
      is_valid(concat(value, head), tail, target) or
      is_valid(value + head, tail, target)
  end

  defp concat(a, b), do: String.to_integer(Integer.to_string(a) <> Integer.to_string(b))
end
