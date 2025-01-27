import Solutions.Day21.Common

# For this first part, we can simply try all inputs. We divide the target
# code into a number chunks, each describing the path from one numpad key
# to the next; for example, for code 029A, we have the chunks A-to-0 (since
# we start on the A), 0-to-2, etc. We can find the shortest path for each of
# these chunks independently of the others, using the knowledge that at the
# end of each chunk, all d-pad robots should be on the A key; this gives us
# both the start state and the end state of each chunk.
#
# We use a recursive function to find the shortest path for each chunk. In
# each step, we try all possible d-pad keys, filtering out those that result
# in an invalid state (i.e. causing a robot to move away from the valid keys),
# as well as those that result in a state that we've already visited for the
# current chunk. Each state in our state queue consists of the current keys
# for the three robots, in order from closest to our position to furthest
# away (i.e. the last state value is the key of the numpad robot).
#
# We keep exhaustively trying all d-pad keys until we reach the target state
# of the current chunk, i.e. the state where the numpad robot is on the next
# code key, and the other robots are on the A key. We then return the number
# of recursive steps it took to reach this state, plus one for the final A
# press. Each chunk only takes around 15 steps to complete, so the number
# of recursive steps before we reach the target state is quite limited,
# and the algorithm runs in a few microseconds without optimizations.

defmodule Solutions.Day21.PartA do
  @options [:a, :u, :d, :l, :r]

  def solve(lines) do
    Enum.sum_by(lines, &solve_line/1)
  end

  defp solve_line(line) do
    keys = Enum.map(String.graphemes(line), &to_key/1)

    length =
      [:a | keys]
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.sum_by(fn [from, to] ->
        initial_queue = [[:a, :a, from]]
        visited = Enum.into(initial_queue, MapSet.new())
        recurse(to, 0, initial_queue, visited) + 1
      end)

    length * get_numeric(line)
  end

  # --------------------------- Recursive function --------------------------- #

  defp recurse(target, count, queue, visited) do
    new_queue =
      queue
      |> Enum.flat_map(fn state ->
        Enum.map(@options, &apply_input(state, &1))
      end)
      |> Enum.filter(&is_valid_state/1)
      |> Enum.reject(&MapSet.member?(visited, &1))
      |> Enum.uniq()

    case Enum.any?(new_queue, &is_target_state(&1, target)) do
      true ->
        count + 1

      false ->
        new_visited = MapSet.union(visited, Enum.into(new_queue, MapSet.new()))
        recurse(target, count + 1, new_queue, new_visited)
    end
  end

  defp is_valid_state(state), do: Enum.all?(state, &(&1 != nil))
  defp is_target_state([:a, :a, tail], target), do: tail == target
  defp is_target_state(_, _), do: false

  defp apply_input([key], input), do: [apply_numpad(key, input)]
  defp apply_input([head | tail], :a), do: [head | apply_input(tail, head)]
  defp apply_input([head | tail], input), do: [apply_dpad(head, input) | tail]

  # ----------------------------- Applying inputs ---------------------------- #

  def apply_dpad(:u, :r), do: :a
  def apply_dpad(:u, :d), do: :d
  def apply_dpad(:a, :l), do: :u
  def apply_dpad(:a, :d), do: :r
  def apply_dpad(:l, :r), do: :d
  def apply_dpad(:d, :l), do: :l
  def apply_dpad(:d, :u), do: :u
  def apply_dpad(:d, :r), do: :r
  def apply_dpad(:r, :l), do: :d
  def apply_dpad(:r, :u), do: :a
  def apply_dpad(_, _), do: nil

  def apply_numpad(key, :a), do: key
  def apply_numpad(:n7, :r), do: :n8
  def apply_numpad(:n7, :d), do: :n4
  def apply_numpad(:n8, :l), do: :n7
  def apply_numpad(:n8, :r), do: :n9
  def apply_numpad(:n8, :d), do: :n5
  def apply_numpad(:n9, :l), do: :n8
  def apply_numpad(:n9, :d), do: :n6
  def apply_numpad(:n4, :u), do: :n7
  def apply_numpad(:n4, :r), do: :n5
  def apply_numpad(:n4, :d), do: :n1
  def apply_numpad(:n5, :u), do: :n8
  def apply_numpad(:n5, :l), do: :n4
  def apply_numpad(:n5, :r), do: :n6
  def apply_numpad(:n5, :d), do: :n2
  def apply_numpad(:n6, :u), do: :n9
  def apply_numpad(:n6, :l), do: :n5
  def apply_numpad(:n6, :d), do: :n3
  def apply_numpad(:n1, :u), do: :n4
  def apply_numpad(:n1, :r), do: :n2
  def apply_numpad(:n2, :u), do: :n5
  def apply_numpad(:n2, :l), do: :n1
  def apply_numpad(:n2, :r), do: :n3
  def apply_numpad(:n2, :d), do: :n0
  def apply_numpad(:n3, :u), do: :n6
  def apply_numpad(:n3, :l), do: :n2
  def apply_numpad(:n3, :d), do: :a
  def apply_numpad(:n0, :u), do: :n2
  def apply_numpad(:n0, :r), do: :a
  def apply_numpad(:a, :u), do: :n3
  def apply_numpad(:a, :l), do: :n0
  def apply_numpad(_, _), do: nil
end
