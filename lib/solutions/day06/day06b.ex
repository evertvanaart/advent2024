import Solutions.Day06.Common

# I ended up going with a simple solution, in which I place the obstacle
# at every step of the regular path (excluding the starting position) and
# check if this results in a loop by tracing a new path from the starting
# position. Every obstacle can potentially produce a completely new path,
# so I'm not sure if it is possible to speed this up by e.g. checking a
# new path against previously discovered loops. Also note that, unlike
# in the examples, a looping path does not have to retrace part of the
# main path; it can potentially loop in a previously unvisited area.
#
# The problem is that checking for loops using the approach of the first
# part – in which we move one step at a time – is very slow, since we need
# to do this for several thousand possible obstacle positions; in my initial
# naive approach, this took more than three seconds. We can speed this up by
# tracing paths in a more efficient way when checking for loops: rather than
# moving one cell at a time, we can immediately skip to the next block (if
# any) in the current direction. This reduces the number of recursions from
# O(number of steps) to O(number of turns), which should be far lower.
#
# To do so, we first create two block maps, one for rows and one for columns.
# The block map for rows maps the row index to a sorted list of column indices
# corresponding to the blocks (#) in that row; the column block map does the
# same but for columns. When placing an obstacle, we first update these block
# maps with the obstacle position, and then use a recursive function to check
# if this results in a loop. While tracing this new path, we only need to keep
# track of the positions and directions of the turns, and we can use the block
# maps to immediately find the position of the next turn. If we encounter a
# turn that we previously encountered, we've entered a loop; otherwise, if
# the path leaves the grid, the path does not contain a loop.
#
# This is already much faster than the naive approach – 125ms instead of 3+
# seconds – but as an exercise I tried using an asynchronous stream to speed
# it up further. One conclusion is that simply passing the 'targets' set (which
# can contain thousands of positions) to Task.async_stream/3 does not result in
# better performance, and in fact makes execution slower. Instead, we divide
# 'targets' into a small number of larger chunks, and process those chunks
# in parallel. The current chunk size was picked more or less arbitrarily,
# and could probably be optimized further, but compared to the synchronous
# stream it does already achieve a speed-up of roughly five times.

defmodule Solutions.Day06.PartB do
  @chunk_size 100

  def solve(lines) do
    start = find_start(lines)
    grid = parse_grid(lines)

    # find all visited positions in the main path
    visited = trace_path(grid, start, :n, MapSet.new())
    targets = MapSet.delete(visited, start)

    {row_blocks, col_blocks} = get_block_maps(lines)

    Task.async_stream(Enum.chunk_every(targets, @chunk_size), fn targets_chunk ->
      targets_chunk
      |> Enum.count(fn {target_row, target_col} ->
        new_row_blocks = update_block_map(row_blocks, target_row, target_col)
        new_col_blocks = update_block_map(col_blocks, target_col, target_row)
        blocks = %{rows: new_row_blocks, cols: new_col_blocks}
        is_loop(blocks, start, :n, MapSet.new())
      end)
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  # ------------------------------ Finding loops ----------------------------- #

  # nil means we've left the grid, so no loop
  defp is_loop(_, {nil, _}, _, _), do: false
  defp is_loop(_, {_, nil}, _, _), do: false

  defp is_loop(blocks, position, direction, turns) do
    # check the set of previous turns to see if we've entered a loop
    case MapSet.member?(turns, {position, direction}) do
      false ->
        new_turns = MapSet.put(turns, {position, direction})
        next_position = next_turn(blocks, position, direction)
        is_loop(blocks, next_position, next_dir(direction), new_turns)

      true ->
        true
    end
  end

  defp next_turn(blocks, {i, j}, :n), do: {add_one(get_lower(blocks.cols, j, i)), j}
  defp next_turn(blocks, {i, j}, :s), do: {sub_one(get_upper(blocks.cols, j, i)), j}
  defp next_turn(blocks, {i, j}, :w), do: {i, add_one(get_lower(blocks.rows, i, j))}
  defp next_turn(blocks, {i, j}, :e), do: {i, sub_one(get_upper(blocks.rows, i, j))}

  defp get_upper(block_map, ia, ib),
    do: Map.get(block_map, ia, []) |> Enum.find(&(&1 > ib))

  defp get_lower(block_map, ia, ib),
    do: Map.get(block_map, ia, []) |> Enum.reverse() |> Enum.find(&(&1 < ib))

  defp add_one(nil), do: nil
  defp add_one(v), do: v + 1

  defp sub_one(nil), do: nil
  defp sub_one(v), do: v - 1

  # ------------------------------- Block maps ------------------------------- #

  defp get_block_maps(lines) do
    block_positions =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, i} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {c, _} -> c == "#" end)
        |> Enum.map(fn {_, j} -> {i, j} end)
      end)
      |> List.flatten()

    row_blocks = Enum.group_by(block_positions, fn {i, _} -> i end, fn {_, j} -> j end)
    col_blocks = Enum.group_by(block_positions, fn {_, j} -> j end, fn {i, _} -> i end)
    {row_blocks, col_blocks}
  end

  defp update_block_map(map, ia, ib),
    do: Map.update(map, ia, [ib], fn l -> Enum.sort(l ++ [ib]) end)
end
