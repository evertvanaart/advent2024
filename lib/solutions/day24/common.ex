defmodule Solutions.Day24.Common do
  # ------------------------------- Logic gates ------------------------------ #

  def resolve_gate(:or, 0, 0), do: 0
  def resolve_gate(:or, _, _), do: 1

  def resolve_gate(:and, 1, 1), do: 1
  def resolve_gate(:and, _, _), do: 0

  def resolve_gate(:xor, 0, 1), do: 1
  def resolve_gate(:xor, 1, 0), do: 1
  def resolve_gate(:xor, _, _), do: 0

  # --------------------------------- Parsing -------------------------------- #

  def parse(lines) do
    {init_lines, [_ | gate_lines]} = Enum.split_while(lines, &(String.length(&1) > 0))
    init_values = parse_init_values(init_lines)
    gates = parse_gate_lines(gate_lines)
    {init_values, gates}
  end

  defp parse_init_values(lines) do
    lines
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [w, v] -> {w, String.to_integer(v)} end)
    |> Enum.into(%{})
  end

  defp parse_gate_lines(lines) do
    lines
    |> Enum.flat_map(fn line ->
      {i1, i2, o, type} = split_gate_line(line)
      [{i1, {i1, i2, o, type}}, {i2, {i2, i1, o, type}}]
    end)
    |> Enum.group_by(fn {i, _} -> i end, fn {_, v} -> v end)
  end

  defp split_gate_line(line) do
    [i1, type, i2, _, o] = String.split(line, " ")
    {i1, i2, o, parse_type(type)}
  end

  defp parse_type("OR"), do: :or
  defp parse_type("AND"), do: :and
  defp parse_type("XOR"), do: :xor
end
