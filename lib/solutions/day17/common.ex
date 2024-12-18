defmodule Solutions.Day17.Common do
  # -------------------------------- Operators ------------------------------- #

  # note for opcodes:
  # co = combo operand
  # lo = literal operand

  # opcode 0 (adv): A = A / (2 ** co)
  def execute(0, operand, pointer, registers) do
    result = div(registers.a, 2 ** combo_operand(operand, registers))
    new_registers = Map.put(registers, :a, result)
    {pointer + 2, new_registers, []}
  end

  # opcode 1 (bxl): B = XOR(B, lo)
  def execute(1, operand, pointer, registers) do
    result = Bitwise.bxor(registers.b, operand)
    new_registers = Map.put(registers, :b, result)
    {pointer + 2, new_registers, []}
  end

  # opcode 2 (bst): B = co % 8
  def execute(2, operand, pointer, registers) do
    result = Integer.mod(combo_operand(operand, registers), 8)
    new_registers = Map.put(registers, :b, result)
    {pointer + 2, new_registers, []}
  end

  # opcode 3 (jnz): jump to lo iff A != 0
  def execute(3, operand, pointer, registers) do
    case registers.a do
      0 -> {pointer + 2, registers, []}
      _ -> {operand, registers, []}
    end
  end

  # opcode 4 (bxc): B = XOR(B, C)
  def execute(4, _, pointer, registers) do
    result = Bitwise.bxor(registers.b, registers.c)
    new_registers = Map.put(registers, :b, result)
    {pointer + 2, new_registers, []}
  end

  # opcode 5 (out): print(co % 8)
  def execute(5, operand, pointer, registers) do
    result = Integer.mod(combo_operand(operand, registers), 8)
    {pointer + 2, registers, [result]}
  end

  # opcode 6 (bdv): B = A / (2 ** co)
  def execute(6, operand, pointer, registers) do
    result = div(registers.a, 2 ** combo_operand(operand, registers))
    new_registers = Map.put(registers, :b, result)
    {pointer + 2, new_registers, []}
  end

  # opcode 7 (cdv): C = A / (2 ** co)
  def execute(7, operand, pointer, registers) do
    result = div(registers.a, 2 ** combo_operand(operand, registers))
    new_registers = Map.put(registers, :c, result)
    {pointer + 2, new_registers, []}
  end

  # ----------------------------- Combo operands ----------------------------- #

  defp combo_operand(0, _), do: 0
  defp combo_operand(1, _), do: 1
  defp combo_operand(2, _), do: 2
  defp combo_operand(3, _), do: 3
  defp combo_operand(4, registers), do: registers.a
  defp combo_operand(5, registers), do: registers.b
  defp combo_operand(6, registers), do: registers.c

  # --------------------------------- Parsing -------------------------------- #

  def parse([line_a, line_b, line_c, "", line_program]) do
    registers = %{
      a: parse_register(line_a),
      b: parse_register(line_b),
      c: parse_register(line_c)
    }

    program = parse_program(line_program)

    {registers, program}
  end

  defp parse_register(line) do
    [_, value] = String.split(line, ": ", parts: 2)
    String.to_integer(value)
  end

  defp parse_program(line) do
    [_, values] = String.split(line, ": ", parts: 2)
    String.split(values, ",") |> Enum.map(&String.to_integer/1)
  end
end
