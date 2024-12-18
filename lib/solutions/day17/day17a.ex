import Solutions.Day17.Common

# For the first part, we simply need to implement the various instructions
# according to the specifications. Each implementation of execute/4 handles
# a different opcode, and they all return the new pointer (usually just the
# input pointer plus two, except for the jump instruction), the new register
# values, and the output characters, if any. We recursively step through the
# program, executing a single instruction in each step, until the exit con-
# dition is triggered (pointer exceeds program length); at this point, we
# recursively return the output characters, and join them into a string.

defmodule Solutions.Day17.PartA do
  def solve(lines) do
    {registers, program} = parse(lines)

    output = recurse(program, 0, registers)
    out_strings = Enum.map(output, &Integer.to_string/1)
    out_string = Enum.join(out_strings, ",")

    out_string
  end

  defp recurse(program, pointer, _) when pointer >= length(program), do: []

  defp recurse(program, pointer, registers) do
    [opcode, operand] = Enum.slice(program, pointer..(pointer + 1))
    {new_pointer, new_registers, out} = execute(opcode, operand, pointer, registers)
    out ++ recurse(program, new_pointer, new_registers)
  end
end
