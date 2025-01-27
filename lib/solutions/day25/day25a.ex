# A straightforward approach for the final day. After parsing the input
# and identifying each block as either a lock or a key, we simply try all
# combinations of locks and keys; a key fits in a lock if at no point the
# sum of the heights of two columns is more than five. This is obviously
# not the most efficient approach, but since there are 250 locks and 250
# keys, trying all 50,000 combinations only takes a few milliseconds.

defmodule Solutions.Day25.PartA do
  def solve(lines) do
    {keys, locks} = parse(lines)

    Enum.sum_by(keys, fn key ->
      Enum.count(locks, fn lock -> fits(key, lock) end)
    end)
  end

  defp fits([], []), do: true
  defp fits([h1 | _], [h2 | _]) when h1 + h2 > 5, do: false
  defp fits([_ | t1], [_ | t2]), do: fits(t1, t2)

  # --------------------------------- Parsing -------------------------------- #

  defp parse(lines) do
    lines
    |> Enum.chunk_every(7, 8)
    |> Enum.reduce({[], []}, fn item, {keys, locks} ->
      case String.at(hd(item), 0) do
        "." -> {keys, [parse_lock(item) | locks]}
        "#" -> {[parse_key(item) | keys], locks}
      end
    end)
  end

  defp parse_lock(lines), do: parse_item(lines, &(6 - &1))
  defp parse_key(lines), do: parse_item(lines, & &1)

  defp parse_item(lines, line_height_function) do
    width = String.length(hd(lines))
    init_heights = List.duplicate(0, width)

    lines
    |> Enum.with_index()
    |> Enum.reduce(init_heights, fn {line, index}, heights ->
      line_height = line_height_function.(index)

      Enum.zip(String.graphemes(line), heights)
      |> Enum.map(fn {char, height} ->
        case char do
          "#" -> max(height, line_height)
          "." -> height
        end
      end)
    end)
  end
end
