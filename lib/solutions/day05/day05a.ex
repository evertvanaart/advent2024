import Solutions.Day05.Common

# Rephrasing the problem, we can say that the rule "A|B" means that the group
# is invalid if we encounter A at any time after B. This means that, if we are
# moving through the group from left to right, we add A to a set of "forbidden"
# values when we encounter B. At every step, if the current value is already in
# this set of forbidden values, we know that the group is invalid.
#
# To this end, we create a rules map, in which each right-hand rules value (B)
# maps to all corresponding left-hand values (e.g., for rules "X|B", "Y|B", and
# "Z|B", we get a mapping of B to [X,Y,Z]). We then use a recursive function to
# check if the group is valid, i.e. if at no point the current head value is in
# the ever-growing set of forbidden characters.

defmodule Solutions.Day05.PartA do
  def solve(lines) do
    {rules, groups} = parse(lines)

    rule_map = rules |> Enum.group_by(fn {_, r} -> r end, fn {l, _} -> l end)
    valid_groups = groups |> Enum.filter(&is_valid(&1, MapSet.new(), rule_map))
    valid_groups |> Enum.map(&get_middle_value/1) |> Enum.sum()
  end

  defp get_middle_value(group) do
    index = div(length(group) - 1, 2)
    Enum.at(group, index)
  end
end
