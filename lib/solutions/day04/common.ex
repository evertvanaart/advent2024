defmodule Solutions.Day04.Common do
  def parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {{i, j}, c} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end
end
