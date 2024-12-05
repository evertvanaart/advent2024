defmodule Solutions.Day05.Common do
  def is_valid([], _, _), do: true

  def is_valid([head | tail], forbidden, rules) do
    case MapSet.member?(forbidden, head) do
      false ->
        new_forbidden = Map.get(rules, head, []) |> Enum.into(MapSet.new())
        is_valid(tail, MapSet.union(forbidden, new_forbidden), rules)

      true ->
        false
    end
  end

  def parse(lines) do
    {rules, [_ | groups]} = lines |> Enum.split_while(&(&1 != ""))

    rules = rules |> Enum.map(&parse_rule/1)
    groups = groups |> Enum.map(&parse_group/1)

    {rules, groups}
  end

  def parse_rule(rule) do
    [l, r] = String.split(rule, "|")
    {String.to_integer(l), String.to_integer(r)}
  end

  def parse_group(group) do
    String.split(group, ",")
    |> Enum.map(&String.to_integer/1)
  end
end
