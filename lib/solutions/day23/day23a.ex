import Solutions.Day23.Common

# We first parse the input list to a network map, in which node names map
# to sets of connected nodes. To find groups of three nodes, we start at
# any node starting with "t", and recursively try moving to any connected
# node. If after exactly three of these recursive steps we are back at the
# node we started at, we've found a group of three connected nodes, and we
# return a set containing the three nodes in this group. We flatten all
# resulting groups of three nodes for all "t"-nodes into a single list,
# and return the number of unique elements in this list.

defmodule Solutions.Day23.PartA do
  def solve(lines) do
    network_map = parse(lines, %{})

    Map.keys(network_map)
    |> Enum.filter(&String.starts_with?(&1, "t"))
    |> Enum.flat_map(&find_groups_of_three(network_map, &1))
    |> Enum.uniq()
    |> length()
  end

  defp find_groups_of_three(network_map, start) do
    Enum.uniq(find_groups(network_map, start, start, 3))
  end

  defp find_groups(_, node, target, 0) when node == target, do: [MapSet.new([node])]
  defp find_groups(_, _, _, 0), do: []

  defp find_groups(network_map, node, target, distance) do
    Map.get(network_map, node)
    |> Enum.flat_map(&find_groups(network_map, &1, target, distance - 1))
    |> Enum.map(&MapSet.put(&1, node))
  end
end
