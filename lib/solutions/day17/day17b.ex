import Solutions.Day17.Common

# I usually try to keep these solutions input-agnostic, but I don't think an
# efficient generic solution is possible here. We can observe that the avail-
# able instructions (division, modulo, and XOR) can never increase the register
# values, so the values should be trending towards zero for all programs and
# initial register states, but I still don't believe we can use this know-
# ledge to design an efficient generic solution (i.e., one that does not
# involve trying all possible initial values of A).
#
# This means that we have to look at our actual program in detail. We can
# see that the program consists of a single loop, with the last instruction
# jumping back to the start if A is not zero. We can also see that the value
# of A is divided by eight every step, and that there is exactly one output
# instruction in the loop. This means that the number of digits in our target
# value for A, when written in base-8, must be the same as the program length.
#
# We should therefore be able to recursively construct A, starting from the
# back. In the very last step, the value of A will be between zero and seven
# (inclusive), so we can try running the program with A set to one of these
# eight digits, knowing that the correct digit will result in the program
# printing its own final value. Adding a second base-8 digit to the right
# of this first digit should produce the last two program values, and so on.
# In this way, we can construct a base-8 representation of the valid A value
# from left to right. For the sake of convenience, we pass this value as a
# base-8 string between steps, and convert it to an integer before running
# the program.
#
# There are a couple of places where more than one new input digit produces
# the correct output program, meaning the recursion will branch, but the
# number of branches is very limited. Once we've found all valid branches
# (i.e. A produces the correct output and its length in base-8 is equal
# to the program length), we return the minimum valid A value.

defmodule Solutions.Day17.PartB do
  @digits ?0..?7 |> Enum.map(fn c -> <<c::utf8>> end)

  def solve(lines) do
    {registers, program} = parse(lines)

    results = find_a(program, registers, 0, "")
    values = Enum.map(results, &String.to_integer(&1, 8))

    Enum.min(values)
  end

  defp find_a(program, registers, step, a) do
    # expected output: last 'step + 1' values of the program
    expected = Enum.slice(program, -(step + 1)..-1)

    valid_digits =
      @digits
      |> Enum.filter(fn digit ->
        new_a = String.to_integer(a <> digit, 8)
        init_registers = Map.put(registers, :a, new_a)
        output = recurse(program, 0, init_registers)
        output == expected
      end)

    cond do
      step == length(program) - 1 ->
        Enum.map(valid_digits, &(a <> &1))

      true ->
        Enum.flat_map(valid_digits, &find_a(program, registers, step + 1, a <> &1))
    end
  end

  defp recurse(program, pointer, _) when pointer >= length(program), do: []

  defp recurse(program, pointer, registers) do
    [opcode, operand] = Enum.slice(program, pointer..(pointer + 1))
    {new_pointer, new_registers, out} = execute(opcode, operand, pointer, registers)
    out ++ recurse(program, new_pointer, new_registers)
  end
end
