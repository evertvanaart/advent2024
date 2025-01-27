import Solutions.Day05.Common

# We could try moving around invalid values (i.e. values that break one or
# more of the given rules) until the group is completely valid, but this is slow
# and error-prone. It's easier to simply reconstruct the group from the ground up
# using the provided rules, on the assumption that there is always exactly one
# unique group ordering that satisfies all rules.
#
# To do so, we first reject all valid groups using the solution of the first
# part. Then, for each invalid group, we recursively reconstruct the group, at
# every step determining which value can be placed next. A value X can be placed
# if all corresponding left-hand rules values (i.e. all values of Y for which
# there is a rule "Y|X") either have already been placed in a previous step,
# or were not part of the group to begin with. After finding this next value
# (again, assuming that there will always be exactly one such value), we
# remove it from the set of remaining values, and move to the next step.
#
# We could actually reconstruct the entire group in this way, but since we
# are only interested in the middle value, we can optimize this by returning
# the next value once we've performed a precomputed number of steps. This also
# means that we do not actually have to keep track of the values we've "placed"
# thus far, allowing us to simplify the signature of the recursive function.
#
# One last thing to note is that this will not work for groups that contain
# duplicate values. There are no such groups in either the sample input or the
# real input, but this uniqueness is not specified in the question either. We
# can make the solution work for groups with duplicate values by changing the
# MapSet to a List, although this does negatively impact runtime complexity.

defmodule Solutions.Day05.PartB do
  def solve(lines) do
    {rules, groups} = parse(lines)
    rule_map = rules |> Enum.group_by(fn {_, r} -> r end, fn {l, _} -> l end)
    invalid_groups = groups |> Enum.reject(&is_valid(&1, MapSet.new(), rule_map))

    middle_values =
      Enum.map(invalid_groups, fn group ->
        steps = div(length(group) - 1, 2)
        values = group |> Enum.into(MapSet.new())
        reconstruct(steps, values, rule_map)
      end)

    middle_values |> Enum.sum()
  end

  defp reconstruct(steps, values, rules) do
    next_value = values |> Enum.find(&can_be_placed(&1, values, rules))

    case steps do
      0 ->
        next_value

      _ ->
        new_values = MapSet.delete(values, next_value)
        reconstruct(steps - 1, new_values, rules)
    end
  end

  defp can_be_placed(value, remaining_values, rules) do
    !(Map.get(rules, value, []) |> Enum.any?(&MapSet.member?(remaining_values, &1)))
  end
end
