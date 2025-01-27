import Solutions.Day09.Common

# We could of course create an array and perform the swaps as described, but
# not only does this intuitively seem inefficient, it also doesn't really play
# to Elixir's strengths, given its lack of array-like data structures. We can
# instead solve it using a recursive function and without performing any
# actual swaps; once we've determined the final position of a block, we
# add its checksum product to the running total without moving it.
#
# To this end, we first parse the input to a list of sectors, each consisting
# of a sector size (in number of blocks) and file ID; a file ID of nil means
# that the sector is empty. We then recursively move through this list using
# two pointers, a forward pointer moving from left to right, and a backward
# pointer moving from right to left. In practice, we create a reversed copy
# of the list for the backward pointer, since list operations on the first
# element are much more efficient than operations on the last element.
#
# During the recursive process, we apply the following rules:
# - If the block at the forward pointer is occupied, compute its checksum
#   product and add it to the running total, then move on to the next block.
# - If the block at the forward pointer is empty, and the block at the backward
#   pointer is occupied, increase the checksum as if we've swapped this element
#   to the forward block, then increase both pointers.
#
# In practice, we do not actually use pointers, we simply remove the head
# sector from a list once we've fully processed it, and recurse on the tail
# of that list. We also keep track of a forward index and backward index; the
# forward index is needed for computing the checksum products, and we can stop
# recursing as soon as the forward index is larger than the backward index.

defmodule Solutions.Day09.PartA do
  def solve(lines) do
    fw_sectors = parse(hd(lines))
    bw_sectors = Enum.reverse(fw_sectors)
    bwi = get_length(fw_sectors) - 1

    recurse(0, bwi, fw_sectors, bw_sectors)
  end

  # Exit condition
  defp recurse(fwi, bwi, _, _) when fwi > bwi, do: 0

  # Remove sectors of size zero at the head of either list.
  defp recurse(fwi, bwi, [{0, _} | fw_tail], bw), do: recurse(fwi, bwi, fw_tail, bw)
  defp recurse(fwi, bwi, fw, [{0, _} | bw_tail]), do: recurse(fwi, bwi, fw, bw_tail)

  # The forward pointer has reached an empty block (first nil), but the backward
  # pointer is also at an empty block (second nil); skip the empty blocks at the
  # start of the backward list in order to reach the next swappable element(s).
  defp recurse(fwi, bwi, [{_, nil} | _] = fw, [{bw_size, nil} | bw_tail]) do
    recurse(fwi, bwi - bw_size, fw, bw_tail)
  end

  # The forward pointer is at an already occupied block; add its value to the
  # checksum, and move to the next block, reducing the head sector size by one.
  defp recurse(fwi, bwi, [{fw_size, fw_id} | fw_tail], bw) when fw_id != nil do
    checksum(fwi, fw_id) +
      recurse(
        fwi + 1,
        bwi,
        [{fw_size - 1, fw_id} | fw_tail],
        bw
      )
  end

  # The forward pointer is at an empty block, and the backwards pointer is at
  # an occupied block; virtually swap the element in the backward pointer block
  # to the forward pointer block (by increasing the checksum as if we've swapped
  # these elements), then reduce the head sector sizes by one for both lists.
  defp recurse(fwi, bwi, [{fw_size, nil} | fw_tail], [{bw_size, bw_id} | bw_tail]) do
    checksum(fwi, bw_id) +
      recurse(
        fwi + 1,
        bwi - 1,
        [{fw_size - 1, nil} | fw_tail],
        [{bw_size - 1, bw_id} | bw_tail]
      )
  end

  defp checksum(index, id), do: index * id
end
