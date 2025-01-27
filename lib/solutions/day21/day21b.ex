import Solutions.Day21.Common

# This is the last question I completed this year, a full month after the
# others. I originally tried to simply compute the path at level X, and then
# expand this to the path at level X + 1, but given that the length per code
# is in the order of 10^12, this approach was clearly not feasible.
#
# I ended up expanding on the idea of the first part, but applying it to
# intermediate D-pads as well. Let's say that the robot at level X is on the
# left arrow, and just pressed this button; this means that all robots on all
# levels above X must be on the A key. If we then want to move robot X to the
# up arrow, robot X-1 must move from A to right, then from right to up, and
# then from up back to A; in addition, the robots _above_ X-1 need to press
# A between each step. This means that we can compute the length of a path
# from one key to another at level X (bookended by A presses) as the sum of
# the lengths of the moves needed for this path at X-1. We can repeat this
# recursive calculation until we're at level 25, i.e. the last d-pad.
#
# Once we've calculated the path lengths at level 25, we can apply the exact
# same principle for the numpad paths. One assumption we made – which luckily
# turned out to be correct – is that we always want to take the path with the
# fewest turns. For example, on the d-pad, moving from A to the left arrow via
# down-left-left will always be quicker than via down-left-down; the former has
# only one 'turn' as opposed to two turns in the latter, meaning we do not have
# to reposition previous robots between the two subsequent left moves. The same
# goes for the numpad, e.g. from A to 1 should always be up-left-left, and never
# left-up-left. If there is more than one path with minimal turns (e.g. from A
# to 2 can be up-left or left-up), we take the one with the shortest length.
#
# At every d-pad level we have a map of only 4*4 elements, and each chunk of
# the full code requires looking up at most two elements in the final d-pad
# map, so this solution is very fast. It could have been a lot cleaner – I
# definitely didn't have to write out the full numpad case-statement – but
# mostly I'm just glad it works.

defmodule Solutions.Day21.PartB do
  @max_level 25

  def solve(lines) do
    dpad_lengths = find_dpad_lengths(0, %{})
    Enum.sum_by(lines, &solve_line(&1, dpad_lengths))
  end

  def solve_line(line, dpad_lengths) do
    keys = Enum.map(String.graphemes(line), &to_key/1)

    length =
      [:a | keys]
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.sum_by(fn [from, to] ->
        find_numpad_length(from, to, dpad_lengths) + 1
      end)

    length * get_numeric(line)
  end

  # ----------------------------- Numpad lengths ----------------------------- #

  defp find_numpad_length(from, to, dpad_lengths) do
    case {from, to} do
      {:a, :n0} -> get_length(dpad_lengths, [:l])
      {:a, :n1} -> get_length(dpad_lengths, [:u, :l, :l])
      {:a, :n2} -> min_length(dpad_lengths, [[:u, :l], [:l, :u]])
      {:a, :n3} -> get_length(dpad_lengths, [:u])
      {:a, :n4} -> get_length(dpad_lengths, [:u, :u, :l, :l])
      {:a, :n5} -> min_length(dpad_lengths, [[:u, :l, :l], [:l, :u, :u]])
      {:a, :n6} -> get_length(dpad_lengths, [:u, :u])
      {:a, :n7} -> get_length(dpad_lengths, [:u, :u, :u, :l, :l])
      {:a, :n8} -> min_length(dpad_lengths, [[:l, :u, :u, :u], [:u, :u, :u, :l]])
      {:a, :n9} -> get_length(dpad_lengths, [:u, :u, :u])
      {:n0, :a} -> get_length(dpad_lengths, [:r])
      {:n0, :n1} -> get_length(dpad_lengths, [:u, :l])
      {:n0, :n2} -> get_length(dpad_lengths, [:u])
      {:n0, :n3} -> min_length(dpad_lengths, [[:u, :r], [:r, :u]])
      {:n0, :n4} -> get_length(dpad_lengths, [:u, :u, :l])
      {:n0, :n5} -> get_length(dpad_lengths, [:u, :u])
      {:n0, :n6} -> min_length(dpad_lengths, [[:u, :u, :r], [:r, :u, :u]])
      {:n0, :n7} -> get_length(dpad_lengths, [:u, :u, :u, :l])
      {:n0, :n8} -> get_length(dpad_lengths, [:u, :u, :u])
      {:n0, :n9} -> min_length(dpad_lengths, [[:u, :u, :u, :r], [:r, :u, :u, :u]])
      {:n1, :a} -> get_length(dpad_lengths, [:r, :r, :d])
      {:n1, :n0} -> get_length(dpad_lengths, [:r, :d])
      {:n1, :n2} -> get_length(dpad_lengths, [:r])
      {:n1, :n3} -> get_length(dpad_lengths, [:r, :r])
      {:n1, :n4} -> get_length(dpad_lengths, [:u])
      {:n1, :n5} -> min_length(dpad_lengths, [[:u, :r], [:r, :u]])
      {:n1, :n6} -> min_length(dpad_lengths, [[:u, :r, :r], [:r, :r, :u]])
      {:n1, :n7} -> get_length(dpad_lengths, [:u, :u])
      {:n1, :n8} -> min_length(dpad_lengths, [[:u, :u, :r], [:r, :u, :u]])
      {:n1, :n9} -> min_length(dpad_lengths, [[:u, :u, :r, :r], [:r, :r, :u, :u]])
      {:n2, :a} -> min_length(dpad_lengths, [[:d, :r], [:r, :d]])
      {:n2, :n0} -> get_length(dpad_lengths, [:d])
      {:n2, :n1} -> get_length(dpad_lengths, [:l])
      {:n2, :n3} -> get_length(dpad_lengths, [:r])
      {:n2, :n4} -> min_length(dpad_lengths, [[:u, :l], [:l, :u]])
      {:n2, :n5} -> get_length(dpad_lengths, [:u])
      {:n2, :n6} -> min_length(dpad_lengths, [[:u, :r], [:r, :u]])
      {:n2, :n7} -> min_length(dpad_lengths, [[:u, :u, :l], [:l, :u, :u]])
      {:n2, :n8} -> get_length(dpad_lengths, [:u, :u])
      {:n2, :n9} -> min_length(dpad_lengths, [[:u, :u, :r], [:r, :u, :u]])
      {:n3, :a} -> get_length(dpad_lengths, [:d])
      {:n3, :n0} -> min_length(dpad_lengths, [[:d, :l], [:l, :d]])
      {:n3, :n1} -> get_length(dpad_lengths, [:l, :l])
      {:n3, :n2} -> get_length(dpad_lengths, [:l])
      {:n3, :n4} -> min_length(dpad_lengths, [[:u, :l, :l], [:l, :l, :u]])
      {:n3, :n5} -> min_length(dpad_lengths, [[:u, :l], [:l, :u]])
      {:n3, :n6} -> get_length(dpad_lengths, [:u])
      {:n3, :n7} -> min_length(dpad_lengths, [[:u, :u, :l, :l], [:l, :l, :u, :u]])
      {:n3, :n8} -> min_length(dpad_lengths, [[:u, :u, :l], [:l, :u, :u]])
      {:n3, :n9} -> get_length(dpad_lengths, [:u, :u])
      {:n4, :a} -> get_length(dpad_lengths, [:r, :r, :d, :d])
      {:n4, :n0} -> get_length(dpad_lengths, [:r, :d, :d])
      {:n4, :n1} -> get_length(dpad_lengths, [:d])
      {:n4, :n2} -> min_length(dpad_lengths, [[:d, :r], [:r, :d]])
      {:n4, :n3} -> min_length(dpad_lengths, [[:d, :r, :r], [:r, :r, :d]])
      {:n4, :n5} -> get_length(dpad_lengths, [:r])
      {:n4, :n6} -> get_length(dpad_lengths, [:r, :r])
      {:n4, :n7} -> get_length(dpad_lengths, [:u])
      {:n4, :n8} -> min_length(dpad_lengths, [[:u, :r], [:r, :u]])
      {:n4, :n9} -> min_length(dpad_lengths, [[:u, :r, :r], [:r, :r, :u]])
      {:n5, :a} -> min_length(dpad_lengths, [[:d, :d, :r], [:r, :d, :d]])
      {:n5, :n0} -> get_length(dpad_lengths, [:d, :d])
      {:n5, :n1} -> min_length(dpad_lengths, [[:d, :l], [:l, :d]])
      {:n5, :n2} -> get_length(dpad_lengths, [:d])
      {:n5, :n3} -> min_length(dpad_lengths, [[:d, :r], [:r, :d]])
      {:n5, :n4} -> get_length(dpad_lengths, [:l])
      {:n5, :n6} -> get_length(dpad_lengths, [:r])
      {:n5, :n7} -> min_length(dpad_lengths, [[:u, :l], [:l, :u]])
      {:n5, :n8} -> get_length(dpad_lengths, [:u])
      {:n5, :n9} -> min_length(dpad_lengths, [[:u, :r], [:r, :u]])
      {:n6, :a} -> get_length(dpad_lengths, [:d, :d])
      {:n6, :n0} -> min_length(dpad_lengths, [[:d, :d, :l], [:l, :d, :d]])
      {:n6, :n1} -> min_length(dpad_lengths, [[:d, :l, :l], [:l, :l, :d]])
      {:n6, :n2} -> min_length(dpad_lengths, [[:d, :l], [:l, :d]])
      {:n6, :n3} -> get_length(dpad_lengths, [:d])
      {:n6, :n4} -> get_length(dpad_lengths, [:l, :l])
      {:n6, :n5} -> get_length(dpad_lengths, [:l])
      {:n6, :n7} -> min_length(dpad_lengths, [[:u, :l, :l], [:l, :l, :u]])
      {:n6, :n8} -> min_length(dpad_lengths, [[:u, :l], [:l, :u]])
      {:n6, :n9} -> get_length(dpad_lengths, [:u])
      {:n7, :a} -> get_length(dpad_lengths, [:r, :r, :d, :d, :d])
      {:n7, :n0} -> get_length(dpad_lengths, [:r, :d, :d, :d])
      {:n7, :n1} -> get_length(dpad_lengths, [:d, :d])
      {:n7, :n2} -> min_length(dpad_lengths, [[:d, :d, :r], [:r, :d, :d]])
      {:n7, :n3} -> min_length(dpad_lengths, [[:d, :d, :r, :r], [:r, :r, :d, :d]])
      {:n7, :n4} -> get_length(dpad_lengths, [:d])
      {:n7, :n5} -> min_length(dpad_lengths, [[:d, :r], [:r, :d]])
      {:n7, :n6} -> min_length(dpad_lengths, [[:d, :r, :r], [:r, :r, :d]])
      {:n7, :n8} -> get_length(dpad_lengths, [:r])
      {:n7, :n9} -> get_length(dpad_lengths, [:r, :r])
      {:n8, :a} -> min_length(dpad_lengths, [[:d, :d, :d, :r], [:r, :d, :d, :d]])
      {:n8, :n0} -> get_length(dpad_lengths, [:d, :d, :d])
      {:n8, :n1} -> min_length(dpad_lengths, [[:d, :d, :l], [:l, :d, :d]])
      {:n8, :n2} -> get_length(dpad_lengths, [:d, :d])
      {:n8, :n3} -> min_length(dpad_lengths, [[:d, :d, :r], [:r, :d, :d]])
      {:n8, :n4} -> min_length(dpad_lengths, [[:d, :l], [:l, :d]])
      {:n8, :n5} -> get_length(dpad_lengths, [:d])
      {:n8, :n6} -> min_length(dpad_lengths, [[:d, :r], [:r, :d]])
      {:n8, :n7} -> get_length(dpad_lengths, [:l])
      {:n8, :n9} -> get_length(dpad_lengths, [:r])
      {:n9, :a} -> get_length(dpad_lengths, [:d, :d, :d])
      {:n9, :n0} -> min_length(dpad_lengths, [[:d, :d, :d, :l], [:l, :d, :d, :d]])
      {:n9, :n1} -> min_length(dpad_lengths, [[:d, :d, :l, :l], [:l, :l, :d, :d]])
      {:n9, :n2} -> min_length(dpad_lengths, [[:d, :d, :l], [:l, :d, :d]])
      {:n9, :n3} -> get_length(dpad_lengths, [:d, :d])
      {:n9, :n4} -> min_length(dpad_lengths, [[:d, :l, :l], [:l, :l, :d]])
      {:n9, :n5} -> min_length(dpad_lengths, [[:d, :l], [:l, :d]])
      {:n9, :n6} -> get_length(dpad_lengths, [:d])
      {:n9, :n7} -> get_length(dpad_lengths, [:l, :l])
      {:n9, :n8} -> get_length(dpad_lengths, [:l])
      _ -> 0
    end
  end

  # ------------------------------ D-pad lengths ----------------------------- #

  defp find_dpad_lengths(@max_level, length_map), do: length_map

  defp find_dpad_lengths(level, length_map) do
    new_length_map = %{
      {:a, :u} => get_length(length_map, [:l]),
      {:a, :l} => get_length(length_map, [:d, :l, :l]),
      {:a, :d} => min_length(length_map, [[:l, :d], [:d, :l]]),
      {:a, :r} => get_length(length_map, [:d]),
      {:u, :a} => get_length(length_map, [:r]),
      {:u, :l} => get_length(length_map, [:d, :l]),
      {:u, :d} => get_length(length_map, [:d]),
      {:u, :r} => min_length(length_map, [[:r, :d], [:d, :r]]),
      {:l, :a} => get_length(length_map, [:r, :r, :u]),
      {:l, :u} => get_length(length_map, [:r, :u]),
      {:l, :d} => get_length(length_map, [:r]),
      {:l, :r} => get_length(length_map, [:r, :r]),
      {:d, :a} => min_length(length_map, [[:r, :u], [:u, :r]]),
      {:d, :u} => get_length(length_map, [:u]),
      {:d, :l} => get_length(length_map, [:l]),
      {:d, :r} => get_length(length_map, [:r]),
      {:r, :a} => get_length(length_map, [:u]),
      {:r, :u} => min_length(length_map, [[:l, :u], [:u, :l]]),
      {:r, :l} => get_length(length_map, [:l, :l]),
      {:r, :d} => get_length(length_map, [:l])
    }

    find_dpad_lengths(level + 1, new_length_map)
  end

  # ---------------------------- Utility functions --------------------------- #

  defp get_length(length_map, dirs) do
    length(dirs) +
      (Enum.chunk_every([:a] ++ dirs ++ [:a], 2, 1, :discard)
       |> Enum.sum_by(fn [from, to] -> Map.get(length_map, {from, to}, 0) end))
  end

  defp min_length(length_map, options) do
    Enum.map(options, &get_length(length_map, &1)) |> Enum.min()
  end
end
