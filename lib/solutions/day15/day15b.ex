import Solutions.Day15.Common

# The approach for horizontal movement is exactly the same as in the first
# part; we can simply treat the two halves of each box as separate single-
# cell boxes when shifting. For vertical moves, the shift logic is the same
# as in the first part for walls or empty cells; the main difference is the
# case where we try to shift to a cell containing a box.
#
# In the first part, we simply recursed to the next position in this case, but
# now we need to recurse to two different positions: the regular next position
# based on the instruction direction, and the position containing the other half
# of the box (which will be to the left or right the next position, depending on
# whether we encountered a left or right half of a box).

# If both branches of this recursive call succeed, it means that no walls were
# encountered and all 'downstream' boxes were successfully pushed; in this case,
# we can proceed with shifting the current position, and return the new grid state.
# If either shift branch failed (due to running into a wall), the entire shift
# action is blocked, and we return the old grid state.

defmodule Solutions.Day15.PartB do
  def solve(lines) do
    {grid_lines, instruction_lines} = split_lines(lines)
    grid_lines = Enum.map(grid_lines, &widen/1)

    instructions = parse_instructions(instruction_lines)
    {grid, start_pos} = parse_grid(grid_lines)

    final_grid = recurse(grid, instructions, start_pos)

    final_grid
    |> Enum.filter(fn {_, v} -> v == :boxl end)
    |> Enum.map(fn {{i, j}, _} -> 100 * i + j end)
    |> Enum.sum()
  end

  defp widen(line) do
    line
    |> String.replace("#", "##")
    |> String.replace("O", "[]")
    |> String.replace(".", "..")
    |> String.replace("@", "@.")
  end

  # ------------------------- Main recursive function ------------------------ #

  defp recurse(grid, [], _), do: grid

  defp recurse(grid, [head | tail], pos) do
    {moved, new_grid} =
      case head do
        :u -> shift_v(grid, head, pos)
        :d -> shift_v(grid, head, pos)
        :l -> shift_h(grid, head, pos)
        :r -> shift_h(grid, head, pos)
      end

    case moved do
      true -> recurse(new_grid, tail, next_pos(pos, head))
      false -> recurse(grid, tail, pos)
    end
  end

  # -------------------------------- Shifting -------------------------------- #

  defp shift_h(grid, dir, pos) do
    next_pos = next_pos(pos, dir)

    case Map.get(grid, next_pos) do
      :empty -> shift_empty(grid, pos, next_pos)
      :boxl -> try_shift_box_h(grid, dir, pos, next_pos)
      :boxr -> try_shift_box_h(grid, dir, pos, next_pos)
      :wall -> {false, grid}
    end
  end

  defp shift_v(grid, dir, pos) do
    {ni, nj} = next_pos = next_pos(pos, dir)

    case Map.get(grid, next_pos) do
      :empty -> shift_empty(grid, pos, next_pos)
      :boxl -> try_shift_box_v(grid, dir, pos, {ni, nj}, {ni, nj + 1})
      :boxr -> try_shift_box_v(grid, dir, pos, {ni, nj}, {ni, nj - 1})
      :wall -> {false, grid}
    end
  end

  defp try_shift_box_v(grid, dir, pos, next_pos_a, next_pos_b) do
    # recursive branch: try shifting from both positions
    {moved_a, new_grid} = shift_v(grid, dir, next_pos_a)
    {moved_b, new_grid} = shift_v(new_grid, dir, next_pos_b)

    case moved_a and moved_b do
      # if both branches succeeded, shift current position
      true -> shift_v(new_grid, dir, pos)
      # otherwise, shift failed
      false -> {false, grid}
    end
  end

  defp try_shift_box_h(grid, dir, pos, next_pos) do
    {moved, new_grid} = shift_h(grid, dir, next_pos)

    case moved do
      true -> shift_h(new_grid, dir, pos)
      false -> {false, grid}
    end
  end

  defp shift_empty(grid, pos, next_pos) do
    current_val = Map.get(grid, pos)
    new_grid = Map.put(grid, pos, :empty)
    new_grid = Map.put(new_grid, next_pos, current_val)
    {true, new_grid}
  end
end
