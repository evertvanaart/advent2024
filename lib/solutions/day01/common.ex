defmodule Solutions.Day01.Common do
  def parse_lines(lines) do
    lines
    |> Stream.map(&String.split/1)
    |> Stream.map(&parse_fields/1)
    |> Enum.unzip()
  end

  defp parse_fields([l, r]), do: {String.to_integer(l), String.to_integer(r)}
end
