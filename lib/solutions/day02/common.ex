defmodule Solutions.Day02.Common do
  def parse_line(line),
    do: line |> String.split() |> Enum.map(&String.to_integer/1)

  def compute_diffs(levels),
    do: levels |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [l, r] -> r - l end)

  def is_safe_diffs(diffs),
    do: is_all_valid_steps(diffs) and (is_all_positive(diffs) or is_all_negative(diffs))

  defp is_all_valid_steps(diffs), do: Enum.all?(diffs, fn d -> abs(d) <= 3 end)
  defp is_all_positive(diffs), do: Enum.all?(diffs, fn d -> d > 0 end)
  defp is_all_negative(diffs), do: Enum.all?(diffs, fn d -> d < 0 end)
end
