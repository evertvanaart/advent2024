import Solutions.Day15.Common

# After parsing the grid, we recursively process each instruction,
# modifying the grid as we push boxes; after processing the final
# instruction, we return the final grid, and use that to calculate
# the sum of the scores of all boxes.
#
# At each step, we use the shift/3 function to try recursively
# try to push elements. We look at the next position in the direction
# of the current instruction; if this is empty, we move whatever's at
# the current position to that empty cell; if it's a wall, the entire
# shift operation is impossible, and nothing moves; and if it's a box,
# we recurse to the position of the box and try shifting from there.
# If this recursive shift succeeds, we try shifting from the current
# position again (since the target cell will now be empty), otherwise
# we do not move and return the old grid.

defmodule Solutions.Day15.PartA do
  def solve(lines) do
    {grid_lines, instruction_lines} = split_lines(lines)
    instructions = parse_instructions(instruction_lines)
    {grid, start_pos} = parse_grid(grid_lines)

    final_grid = recurse(grid, instructions, start_pos)

    final_grid
    |> Enum.filter(fn {_, v} -> v == :box end)
    |> Enum.map(fn {{i, j}, _} -> 100 * i + j end)
    |> Enum.sum()
  end

  # ------------------------- Main recursive function ------------------------ #

  defp recurse(grid, [], _), do: grid

  defp recurse(grid, [head | tail], pos) do
    {moved, new_grid} = shift(grid, head, pos)

    case moved do
      # if the shift succeeded, use the new grid and position
      true -> recurse(new_grid, tail, next_pos(pos, head))
      # if not, use the old grid and position
      false -> recurse(grid, tail, pos)
    end
  end

  # -------------------------------- Shifting -------------------------------- #

  defp shift(grid, dir, pos) do
    next_pos = next_pos(pos, dir)

    case Map.get(grid, next_pos) do
      # shift the current value to the empty position
      :empty -> shift_empty(grid, pos, next_pos)
      # recurse on the position of the box
      :box -> try_shift_box(grid, dir, pos, next_pos)
      # shifting is not possible
      :wall -> {false, grid}
    end
  end

  defp shift_empty(grid, pos, next_pos) do
    current_val = Map.get(grid, pos)
    new_grid = Map.put(grid, pos, :empty)
    new_grid = Map.put(new_grid, next_pos, current_val)
    {true, new_grid}
  end

  defp try_shift_box(grid, dir, pos, next_pos) do
    # try to shift the box at the next position
    {moved, new_grid} = shift(grid, dir, next_pos)

    case moved do
      # if the recursive call succeeded, try shifting from
      # the current position again using the new grid state
      true -> shift(new_grid, dir, pos)
      # if the recursive call failed (i.e. we ran into a wall),
      # propagate this failure and keep the old grid state
      false -> {false, grid}
    end
  end
end
