import Solutions.Day20.Common

# We start by constructing two minimum-distance maps: one with the minimum
# distance from the start to each non-wall position, and one with the minimum
# distance from the finish. We use a standard recursive approach to get these
# maps, using the intermediate minimum distance maps as memoization maps.
#
# Once we have both maps, we can get the regular fastest time by looking up
# the finish position in the 'minimum distance from start' map. Then, for each
# position in this 'from start' map, we check all four neighbors at a distance
# of two spaces (i.e. skipping one adjacent cell); for each neighbor, we then
# calculate the new cost if we were to cheat from the current position to that
# neighbor; this cost is equal to the minimum distance from the start for the
# current position, plus the minimum distance from the neighbor to the finish,
# plus two (the cost of the cheat itself). We filter the resulting valid
# cheats to get the ones reduce the total time by at least 100ps.
#
# As I was working on the second part, I realized that this approach is not
# completely correct, since it does not allow for diagonal cheats; if we have
# a two-by-two square with empty cells in two opposite corners and walls in
# the other two corners, a diagonal cheat could create a path from one empty
# cell to the other, potentially reducing the total time. My implementation
# does not account for this, it only considers straight cheats. Looking at
# the input however, this situation does not appear to occur in practice.

defmodule Solutions.Day20.PartA do
  def solve(lines) do
    walls = parse_grid(lines)
    start = find_position(lines, "S")
    finish = find_position(lines, "E")

    start_task = Task.async(fn -> find_shortest(walls, start, 0, %{}) end)
    finish_task = Task.async(fn -> find_shortest(walls, finish, 0, %{}) end)

    distance_from_start = Task.await(start_task)
    distance_from_finish = Task.await(finish_task)
    fastest = Map.get(distance_from_start, finish)

    cheats = find_cheats(fastest, distance_from_start, distance_from_finish)

    Enum.count(cheats, fn cost -> fastest - cost >= 100 end)
  end

  defp find_cheats(fastest, from_start, from_finish) do
    Enum.flat_map(from_start, &find_cheat(fastest, from_finish, &1))
  end

  defp find_cheat(fastest, from_finish, {position, cost}) do
    get_neighbors(position, 2)
    |> Enum.filter(fn neighbor -> Map.has_key?(from_finish, neighbor) end)
    |> Enum.map(fn neighbor -> Map.get(from_finish, neighbor) + cost + 2 end)
    |> Enum.filter(fn new_cost -> new_cost < fastest end)
  end
end
