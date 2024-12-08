defmodule Solutions.Day08.Common do
  def get_all_pairs([]), do: []
  def get_all_pairs([_]), do: []
  def get_all_pairs([head | tail]), do: (tail |> Enum.map(&{head, &1})) ++ get_all_pairs(tail)

  def get_dimensions(lines), do: {length(lines), String.length(hd(lines))}
  def is_in_grid({i, j}, {rows, cols}), do: i >= 0 and i < rows and j >= 0 and j < cols

  def parse_groups(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {c, _} -> c == "." end)
      |> Enum.map(fn {c, j} -> {c, {i, j}} end)
    end)
    |> List.flatten()
    |> Enum.group_by(fn {c, _} -> c end, fn {_, p} -> p end)
    |> Map.values()
  end
end
