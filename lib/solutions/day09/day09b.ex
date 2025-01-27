import Solutions.Day09.Common

# We first split the input into two list: a list of empty sectors (consisting
# of starting index and size), and a list of files (starting index, size, and
# ID). We then recurse backward through the file list, and try to place each
# file in the leftmost empty sector that can fit it.
#
# To place a file, we first use Enum.split_while/2 to split the list of empty
# sectors just before the sector with size equal to or larger than the target
# file size. If there is such a sector (i.e. the second half of the split call
# is non-empty) and its index is less than the file index (i.e. it is to the
# left of the target file), we can move it; otherwise, it stays in place.
#
# If we move the file, we compute its checksum at the new position (i.e. at
# the index of the empty sector), and update the list of empty sectors; either
# we remove the target empty sector completely (if its size is exactly equal to
# the file size), or we reduce it by the file size. If we do not move the file,
# we only need to calculate the checksum at its current position.
#
# Repeating this for all files (even the very first one, which by definition
# will not be moved) gives us the checksum component of all files, computed at
# their final position, and we can sum those components to get our answer.

defmodule Solutions.Day09.PartB do
  def solve(lines) do
    sectors = parse(hd(lines))
    sectors = add_indices(sectors)

    empty_sectors =
      sectors
      |> Enum.filter(fn {_, _, id} -> id == nil end)
      |> Enum.filter(fn {_, size, _} -> size > 0 end)
      |> Enum.map(fn {index, size, _} -> {index, size} end)

    files =
      sectors
      |> Enum.filter(fn {_, _, id} -> id != nil end)
      |> Enum.reverse()

    place_files(files, empty_sectors)
  end

  defp place_files([], _), do: 0

  defp place_files([{f_index, f_size, f_id} | f_tail], empty_sectors) do
    {es_head, es_tail} =
      empty_sectors
      |> Enum.split_while(fn {s_index, s_size} ->
        s_size < f_size and s_index < f_index
      end)

    es_index = head_index(es_tail)
    can_move = es_index < f_index

    case can_move do
      true ->
        new_es = update_empty_sectors(es_head, es_tail, f_size)
        checksum = checksum(es_index, f_size, f_id)
        checksum + place_files(f_tail, new_es)

      false ->
        checksum = checksum(f_index, f_size, f_id)
        checksum + place_files(f_tail, empty_sectors)
    end
  end

  # Compute checksum for a file
  defp checksum(_, 0, _), do: 0
  defp checksum(index, size, id), do: index * id + checksum(index + 1, size - 1, id)

  # Get index of head sector
  defp head_index([]), do: nil
  defp head_index([{index, _} | _]), do: index

  # Update the list of empty sectors after placing a file of input size in the
  # first sector of the second list; if the size of that sector is exactly equal
  # to the file size we remove the empty sector (first recombine/3), otherwise
  # we shift its starting index and reduce its size by the file size.
  defp update_empty_sectors(head, [{index, sector_size} | tail], file_size) do
    recombine(head, {index + file_size, sector_size - file_size}, tail)
  end

  defp recombine(head, {_, 0}, tail), do: head ++ tail
  defp recombine(head, middle, tail), do: head ++ [middle] ++ tail

  # Add starting index to each sector
  defp add_indices(sectors) do
    {out, _} =
      sectors
      |> Enum.map_reduce(0, fn {size, id}, acc ->
        {{acc, size, id}, acc + size}
      end)

    out
  end
end
