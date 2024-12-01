import Solutions.Day01.Common

defmodule Solutions.Day01.PartA do
  def solve(lines) do
    {left, right} = parse_lines(lines)

    Enum.zip(Enum.sort(left), Enum.sort(right))
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end
end
