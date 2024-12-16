defmodule Solutions.Day14.Common do
  def calculate_position({{px, py}, {vx, vy}}, {rows, cols}, steps) do
    x = Integer.mod(px + steps * vx, cols)
    y = Integer.mod(py + steps * vy, rows)
    {x, y}
  end

  def parse_line(line, {rows, cols}) do
    [px, py, vx, vy] =
      Regex.run(~r/p=(.+),(.+) v=(.+),(.+)/, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    vx = adjust_speed(vx, cols)
    vy = adjust_speed(vy, rows)

    {{px, py}, {vx, vy}}
  end

  defp adjust_speed(v, size) when v < 0, do: v + size
  defp adjust_speed(v, _), do: v
end
