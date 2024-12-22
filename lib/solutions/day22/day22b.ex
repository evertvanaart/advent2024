import Solutions.Day22.Common

# We first calculate a list of the first 2000 values using a recursive
# approach similar to that of the first part. We then map those values to
# their least significant digit (i.e. we compute their modulo-10), compute
# the differences between pairs, and then map each sequence of the last four
# differences to the current modulo-10 value. These pairs then get fed into a
# map, where we store only the value for the first occurence of each sequence.
# For each input value, this gives us a map of difference sequence to mod-10
# value (i.e., price) at the first occurence of that sequence.
#
# We next merge all sequence maps for all input values into a single map.
# While merging, we resolve conflicts by adding up the two values, i.e. if
# a sequence is present in both maps, we store the sum of their values in the
# merged map. This means that the final merged map contains for each sequence
# the total number of bananas we would get if we were to pick that sequence,
# and we can compute the maximum value in this merged map to get our answer.
#
# This is my slowest solution so far this year, but using an asynchronous
# stream it still runs in less than a second. The only optimization worth
# noting is that I identify sequences by an integer key computed from the
# four individual values (using the knowledge that all differences are
# in the range of -9 to +9), rather than by a list or tuple containing
# four values, since single-integer keys are faster.

defmodule Solutions.Day22.PartB do
  def solve(lines) do
    merged_maps =
      get_line_chunks(lines)
      |> Task.async_stream(fn lines ->
        lines
        |> Enum.map(&String.to_integer/1)
        |> Enum.map(&calculate_diffs/1)
        |> Enum.map(&to_sequences/1)
        |> merge_maps()
      end)
      |> Enum.map(fn {:ok, result} -> result end)

    merge_maps(merged_maps)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.max()
  end

  defp merge_maps(maps) do
    Enum.reduce(maps, %{}, fn map, acc ->
      Map.merge(acc, map, fn _, v1, v2 -> v1 + v2 end)
    end)
  end

  # ----------------- Converting differences to sequence maps ---------------- #

  defp to_sequences(diffs) do
    diffs
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.map(&convert_sequence/1)
    |> Enum.reduce(%{}, fn {seq, val}, acc ->
      Map.put_new(acc, seq, val)
    end)
  end

  defp convert_sequence([{a, _}, {b, _}, {c, _}, {d, val}]), do: {to_key(a, b, c, d), val}
  defp to_key(a, b, c, d), do: 8000 * (a + 10) + 400 * (b + 10) + 20 * (c + 10) + (d + 10)

  # ------------------------- Calculating differences ------------------------ #

  defp calculate_diffs(value) do
    [value | get_values(value, 2000)]
    |> Enum.map(&Integer.mod(&1, 10))
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [l, r] -> {r - l, r} end)
  end

  defp get_values(value, 0), do: [value]

  defp get_values(value, step) do
    value = mix_prune(value, value * 64)
    value = mix_prune(value, div(value, 32))
    value = mix_prune(value, value * 2048)

    [value] ++ get_values(value, step - 1)
  end
end
