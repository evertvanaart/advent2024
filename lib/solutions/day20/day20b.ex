import Solutions.Day20.Common

# Similar to the first part, but when finding all cheats, instead of checking
# only the four neighbors at a distance of two, we now check all cells with a
# Manhattan distance of twenty or less. We generate all offsets for this area
# once at the start, see generate_offsets/0. For each offset, we compute the
# new cost if we were to cheat from the current position to the current posi-
# tion plus the offset; this cost is calculated as the minimum distance to the
# start at the current position (the start of the cheat) plus the minimum dis-
# tance to the finish at the target position (the end of the cheat) plus the
# cost of the cheat itself, i.e. its Manhattan distance.
#
# Checking over 800 offsets for every single non-wall position is obviously
# not very efficient, but using an asynchronous stream for basic parallel
# processing we are still able to keep the runtime to around 100ms.

defmodule Solutions.Day20.PartB do
  @max_cheat 20

  def solve(lines) do
    walls = parse_grid(lines)
    start = find_position(lines, "S")
    finish = find_position(lines, "E")
    offsets = generate_offsets()

    start_task = Task.async(fn -> find_shortest(walls, start, 0, %{}) end)
    finish_task = Task.async(fn -> find_shortest(walls, finish, 0, %{}) end)

    distance_from_start = Task.await(start_task)
    distance_from_finish = Task.await(finish_task)
    fastest = Map.get(distance_from_start, finish)

    chunk_count = System.schedulers_online() * 4
    chunk_size = max(div(map_size(distance_from_start), chunk_count), 1)
    pos_chunks = Enum.chunk_every(distance_from_start, chunk_size)

    pos_chunks
    |> Task.async_stream(&find_cheats(fastest, offsets, &1, distance_from_finish))
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp find_cheats(fastest, offsets, from_start, from_finish) do
    Enum.map(from_start, &find_cheat(fastest, offsets, from_finish, &1)) |> Enum.sum()
  end

  defp find_cheat(fastest, offsets, from_finish, {position, cost}) do
    offsets
    |> Stream.map(fn offset -> add_offset(position, offset) end)
    |> Stream.map(fn neighbor -> {neighbor, Map.get(from_finish, neighbor)} end)
    |> Stream.reject(fn {_, distance_from_finish} -> distance_from_finish == nil end)
    |> Stream.map(fn {neighbor, dist} -> dist + cost + offset_cost(position, neighbor) end)
    |> Enum.count(fn new_cost -> fastest - new_cost >= 100 end)
  end

  defp offset_cost({px, py}, {nx, ny}), do: abs(px - nx) + abs(py - ny)

  defp generate_offsets() do
    -@max_cheat..@max_cheat
    |> Enum.flat_map(fn offset_i ->
      max_j = @max_cheat - abs(offset_i)

      -max_j..max_j
      |> Enum.map(fn offset_j ->
        {offset_i, offset_j}
      end)
    end)
  end
end
