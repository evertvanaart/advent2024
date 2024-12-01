defmodule Solutions.Day01.Common do
  def parse_lines(lines) do
    lines
    |> Enum.map(&String.split/1)
    |> Enum.map(&convert_fields/1)
    |> Enum.unzip()
  end

  defp convert_fields([left, right]), do: {String.to_integer(left), String.to_integer(right)}
end
