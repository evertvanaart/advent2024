import Solutions.Day01.Common

defmodule Solutions.Day01.PartB do
  def solve(lines) do
    {left, right} = parse_lines(lines)

    lfreqs = Enum.frequencies(left)
    rfreqs = Enum.frequencies(right)

    lfreqs |> Enum.map(fn {v, f} -> v * f * Map.get(rfreqs, v, 0) end) |> Enum.sum()
  end
end
