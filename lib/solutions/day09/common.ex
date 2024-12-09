defmodule Solutions.Day09.Common do
  def parse(line) do
    line
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 2, [0])
    |> Enum.with_index()
    |> Enum.map(fn {[full, empty], id} ->
      [{full, id}, {empty, nil}]
    end)
    |> List.flatten()
  end

  def get_length(sectors), do: Enum.map(sectors, fn {s, _} -> s end) |> Enum.sum()
end
