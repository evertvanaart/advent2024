import Solutions.Day23.Common

# I initially wrote a naive approach wherein I recursively tried adding nodes
# to a group, and after each new node, I checked if the group was still fully
# connected (i.e. if all of the group nodes were directly connected to the
# new node), but this ended up being far too slow to be feasible.
#
# Instead, we start with a list of single-node groups, and in each step try
# to expand each group to include one more node. We can add node X to group G
# if X is directly connected to all nodes of G. Starting with a valid group of
# size N, we can thus create zero or more new groups of size N + 1. After doing
# this for all groups of size N, we remove duplicate groups, and use the result
# as input for the next expansion step. If a group has reached its maximum size,
# the expand/2 function will return an empty list, and it will automatically be
# removed from the list of valid groups. We keep expanding until there is one
# valid group left, after which we return a string containing its nodes.
#
# This solution takes around two seconds when running single-threaded; using
# a parallel stream when expanding groups reduces this to less than a second.

defmodule Solutions.Day23.PartB do
  def solve(lines) do
    network_map = parse(lines, %{})

    groups =
      Map.keys(network_map)
      |> Enum.map(&MapSet.new([&1]))

    [largest_group] =
      0..map_size(network_map)
      |> Enum.reduce_while(groups, fn _, groups ->
        new_groups = expand_groups(network_map, groups)
        cont = if is_done(new_groups), do: :halt, else: :cont
        {cont, new_groups}
      end)

    group_to_string(largest_group)
  end

  def is_done([_]), do: true
  def is_done(_), do: false

  def group_to_string(group) do
    MapSet.to_list(group)
    |> Enum.sort()
    |> Enum.join(",")
  end

  # ---------------------------- Expanding groups ---------------------------- #

  defp expand_groups(network_map, groups) do
    get_chunks(groups)
    |> Task.async_stream(fn chunk ->
      chunk
      |> Enum.flat_map(&expand(network_map, &1))
      |> Enum.uniq()
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp expand(network_map, group) do
    link_sets = Enum.map(group, &Map.get(network_map, &1))

    valid_links =
      tl(link_sets)
      |> Enum.reduce(hd(link_sets), fn links, acc ->
        MapSet.intersection(links, acc)
      end)

    Enum.map(valid_links, &MapSet.put(group, &1))
  end
end
