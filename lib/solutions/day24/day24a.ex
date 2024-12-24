import Solutions.Day24.Common

# We parse the input to get a map of wires to their initial values, as well as
# a map of wires to all gates for which that wire is an input. These gates are
# expressed as tuples of format {input1, input2, output, type}, where the first
# three fields are wire names, and the last field is the gate type. The inputs
# are ordered in such a way that the other input wire always comes second; for
# example, for a gate with inputs A and B, the gate tuple for wire A will be
# {A, B, _, _}, while the gate tuple for wire B will be {B, A, _, _}); this
# was done to simplify the subsequent logic.
#
# We then execute a recursive function. In each step, we have a list of wires
# to check. For each of these wires, we check which of its connected gates are
# ready to be resolved, meaning 1) their output is not set yet, and 2) the other
# input value is also available (this is where the tuple ordering is helpful).
# For each of these ready gates, we compute the output value, and we add the
# name of the output wire to the list of wires to check in the next step. We
# could also simply check all gates every step to see which ones are ready to
# be resolved, but limiting ourselves to gates connected to outputs set in the
# previous step is more efficient. When there are no more new wires to check,
# the network has reached its final state, and we find and sort the z-values.

defmodule Solutions.Day24.PartA do
  def solve(lines) do
    {values, gates} = parse(lines)

    final_values = recurse(gates, Map.keys(values), values)

    binary =
      final_values
      |> Enum.filter(fn {gate, _} -> String.starts_with?(gate, "z") end)
      |> Enum.sort_by(fn {gate, _} -> gate end, :desc)
      |> Enum.map(fn {_, value} -> Integer.to_string(value) end)
      |> Enum.join()

    String.to_integer(binary, 2)
  end

  defp recurse(_, [], values), do: values

  defp recurse(gates, wires_to_check, values) do
    {new_values, new_wires_to_check} =
      Enum.uniq(wires_to_check)
      |> Enum.filter(&Map.has_key?(gates, &1))
      |> Enum.flat_map(&Map.get(gates, &1))
      |> Enum.reject(fn {_, _, o, _} -> Map.has_key?(values, o) end)
      |> Enum.filter(fn {_, other, _, _} -> Map.has_key?(values, other) end)
      |> Enum.reduce({values, []}, fn {i1, i2, o, type}, {values_acc, check_acc} ->
        in_value1 = Map.get(values_acc, i1)
        in_value2 = Map.get(values_acc, i2)
        out_value = resolve_gate(type, in_value1, in_value2)
        new_values_acc = Map.put_new(values_acc, o, out_value)
        new_check_acc = [o] ++ check_acc
        {new_values_acc, new_check_acc}
      end)

    recurse(gates, new_wires_to_check, new_values)
  end
end
