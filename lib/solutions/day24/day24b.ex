import Solutions.Day24.Common

# We break the binary adder network into a number of stages, with each stage
# consisting of three inputs (one bit from X, one bit from Y, and a carry bit)
# as well as two outputs (one bit from Z and the output carry bit), using the
# output carry bit of one stage as the input carry bit of the next stage. This
# approach allows us to verify and fix the network one stage at a time.
#
# For each stage, we first try to find the name of the output carry wire.
# We do so by setting the current X and Y bits and the input carry bit (from
# the previous stage) to zero, and running the network until we cannot resolve
# any more gates. If the basic network topology is correct, this will result
# in two dangling outputs (i.e. outputs that are not connected only to fully
# resolved gates); one should be the Z output bit, and the other one should
# be the output carry bit of this stage. If we find fewer or more dangling
# outputs, the basic network topology is wrong, and we need to swap wires.
#
# Having determined the output carry wire, we then check all eight possible
# input value combinations, and check if the output and presumed carry output
# are correct for each input. If this is the case, the current stage is correct,
# and we move onto the next one. If not, we try swapping all possible combina-
# tions of the wires of the current stage. We do not actually modify the gate
# map to perform swaps; rather, we keep track of swapped wires in a map, and
# use this map to virtually swap outputs as needed during resolve_stage/4.
# Once we reach the final step (when there are no more new X and Y input
# bits), we return the current swap map, and return its sorted keys.
#
# As it turns out, we can fix the complete network by only swapping outputs
# within the same stage, i.e. it is never necessary to swap outputs from two
# completely different stages. We also never need to swap more than once per
# stage to fix a stage. Combined, these properties allow us to limit the number
# of swap attempts and simplify the control flow, at the cost of leaving certain
# edge-cases uncovered. Since the current solution is already fairly complex,
# I've opted not to account for those theoretical edge-cases.

defmodule Solutions.Day24.PartB do
  # dummy wire, used as carry input in the first stage
  @dummy_wire "---"

  # inputs and expected outputs for each adder stage
  # format: { input1, input2, carry_in, output, carry_out}
  @truth_table [
    {0, 0, 0, 0, 0},
    {0, 0, 1, 1, 0},
    {0, 1, 0, 1, 0},
    {0, 1, 1, 0, 1},
    {1, 0, 0, 1, 0},
    {1, 0, 1, 0, 1},
    {1, 1, 0, 0, 1},
    {1, 1, 1, 1, 1}
  ]

  def solve(lines) do
    {_, gates} = parse(lines)
    swaps = recurse(gates, 0, @dummy_wire, %{})
    Map.keys(swaps) |> Enum.sort() |> Enum.join(",")
  end

  # ------------------------- Main recursive function ------------------------ #
  defp recurse(gates, step, carry_in, swaps) do
    {x, y, z} = step_strings(step)

    if Map.has_key?(gates, x) and Map.has_key?(gates, y) do
      # validate stage topology and find the name of the output wire
      {valid, wires, carry_out} = find_carry_out(gates, swaps, x, y, z, carry_in)

      # validate state by trying all possible input values
      valid = valid and try_all_values(gates, swaps, x, y, z, carry_in, carry_out)

      case valid do
        true ->
          # stage is valid, continue to the next one
          recurse(gates, step + 1, carry_out, swaps)

        false ->
          # stage is not valid, try swapping wires
          wires = Enum.reject(wires, &(&1 == x))
          wires = Enum.reject(wires, &(&1 == y))
          try_swaps(gates, step, carry_in, swaps, wires)
      end
    else
      # no more input bits means we've reached the end, and all
      # stages are valid; return the swap map that fixes the network
      swaps
    end
  end

  defp step_string(step), do: String.pad_leading(Integer.to_string(step), 2, ["0"])

  defp step_strings(step) do
    step_string = step_string(step)
    {"x" <> step_string, "y" <> step_string, "z" <> step_string}
  end

  # ----------------------------- Swapping wires ----------------------------- #

  defp try_swaps(gates, step, carry_in, swaps, wires) do
    {x, y, z} = step_strings(step)

    combinations(wires, 2)
    |> Stream.map(fn [out1, out2] ->
      # virtually swap out1 and out2
      swaps = Map.put(swaps, out1, out2)
      swaps = Map.put(swaps, out2, out1)

      # check if the stage is valid with this new swap configuration
      {valid, _, carry_out} = find_carry_out(gates, swaps, x, y, z, carry_in)
      valid = valid and try_all_values(gates, swaps, x, y, z, carry_in, carry_out)

      case valid do
        true -> recurse(gates, step + 1, carry_out, swaps)
        false -> nil
      end
    end)
    |> Enum.find(&(&1 != nil))
  end

  def combinations(_, 0), do: [[]]
  def combinations([], _), do: []

  def combinations([head | tail], n) do
    Enum.map(combinations(tail, n - 1), &[head | &1]) ++ combinations(tail, n)
  end

  # -------------------------- Finding carry output -------------------------- #

  defp find_carry_out(gates, swaps, x_gate, y_gate, z_gate, carry) do
    init_wires = [x_gate, y_gate, carry]
    in_values = %{x_gate => 0, y_gate => 0, carry => 0}

    # run network with given inputs until we cannot resolve any more gates
    out_values = resolve_stage(gates, swaps, init_wires, in_values)

    cond do
      !Map.has_key?(out_values, z_gate) ->
        # target z-bit should be set
        {false, [], nil}

      true ->
        wires = Map.keys(out_values)

        # find dangling outputs, i.e. wires that either do not serve as input
        # for any gate (z-bits), or wires for which a connected gate is not yet
        # fully resolved, i.e. waiting for the other input wire

        dangling_outputs =
          wires
          |> Enum.reject(&is_finished(gates, out_values, &1))
          |> Enum.reject(&(&1 == @dummy_wire))
          |> Enum.reject(&(&1 == z_gate))

        case length(dangling_outputs) do
          1 -> {true, wires, hd(dangling_outputs)}
          _ -> {false, [], nil}
        end
    end
  end

  defp is_finished(gates, values, wire) do
    case Map.get(gates, wire, nil) do
      nil ->
        false

      gate_list ->
        Enum.all?(gate_list, fn {_, i, _, _} -> Map.has_key?(values, i) end)
    end
  end

  # ---------------------------- Validating logic ---------------------------- #

  defp try_all_values(gates, swaps, x_gate, y_gate, z_gate, carry_in, carry_out) do
    get_truth_table(carry_in)
    |> Enum.all?(fn {i1, i2, ci, xo, xc} ->
      init_wires = [x_gate, y_gate, carry_in]
      in_values = %{x_gate => i1, y_gate => i2, carry_in => ci}
      out_values = resolve_stage(gates, swaps, init_wires, in_values)

      ao = Map.get(out_values, z_gate)
      ac = Map.get(out_values, carry_out)
      ac == xc and ao == xo
    end)
  end

  defp get_truth_table(carry_in) do
    case carry_in do
      # skip carry in lines for the very first stage, i.e. when carry in is "---"
      @dummy_wire -> Enum.reject(@truth_table, fn {_, _, ci, _, _} -> ci == 1 end)
      _ -> @truth_table
    end
  end

  # ----------------------------- Running network ---------------------------- #

  defp resolve_stage(_, _, [], values), do: values

  defp resolve_stage(gates, swaps, wires_to_check, values) do
    {new_values, new_wires_to_check} =
      Enum.uniq(wires_to_check)
      |> Enum.filter(&Map.has_key?(gates, &1))
      |> Enum.flat_map(&Map.get(gates, &1))
      |> Enum.filter(fn {_, other, _, _} -> Map.has_key?(values, other) end)
      |> Enum.reject(fn {_, _, o, _} -> Map.has_key?(values, swap(swaps, o)) end)
      |> Enum.reduce({values, []}, fn {i1, i2, o, type}, {values_acc, check_acc} ->
        # virtual output swap
        out_gate = swap(swaps, o)

        in_value1 = Map.get(values_acc, i1)
        in_value2 = Map.get(values_acc, i2)
        out_value = resolve_gate(type, in_value1, in_value2)
        new_values_acc = Map.put_new(values_acc, out_gate, out_value)
        new_check_acc = [out_gate] ++ check_acc
        {new_values_acc, new_check_acc}
      end)

    resolve_stage(gates, swaps, new_wires_to_check, new_values)
  end

  defp swap(swaps, wire), do: Map.get(swaps, wire, wire)
end
