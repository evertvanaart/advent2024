defmodule Solutions.Day15.Common do
  def next_pos({i, j}, :u), do: {i - 1, j}
  def next_pos({i, j}, :d), do: {i + 1, j}
  def next_pos({i, j}, :l), do: {i, j - 1}
  def next_pos({i, j}, :r), do: {i, j + 1}

  def split_lines(lines) do
    empty_index = Enum.find_index(lines, &(&1 == ""))
    {grid_lines, [_ | instruction_lines]} = Enum.split(lines, empty_index)
    {grid_lines, instruction_lines}
  end

  def parse_grid(lines) do
    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, i} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, j} -> {{i, j}, get_cell_type(c)} end)
      end)
      |> Enum.into(%{})

    {start_pos, _} = Enum.find(grid, fn {_, v} -> v == :robot end)
    {grid, start_pos}
  end

  defp get_cell_type("@"), do: :robot
  defp get_cell_type("."), do: :empty
  defp get_cell_type("#"), do: :wall
  defp get_cell_type("["), do: :boxl
  defp get_cell_type("]"), do: :boxr
  defp get_cell_type("O"), do: :box

  def parse_instructions(lines) do
    Enum.join(lines)
    |> String.graphemes()
    |> Enum.map(&get_instruction_type/1)
  end

  defp get_instruction_type("^"), do: :u
  defp get_instruction_type("v"), do: :d
  defp get_instruction_type("<"), do: :l
  defp get_instruction_type(">"), do: :r
end
