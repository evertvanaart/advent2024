defmodule Solutions.Day03.Common do
  def process_mul(input) do
    matches = Regex.scan(~r/mul\((\d+),(\d+)\)/, input, capture: :all_but_first)

    matches
    |> Stream.map(fn [l, r] -> String.to_integer(l) * String.to_integer(r) end)
    |> Enum.sum()
  end
end
