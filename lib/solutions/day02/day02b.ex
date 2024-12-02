import Solutions.Day02.Common

# The naive approach would be to, upon finding an unsafe list, remove the level
# at index i for all possible values of i, and checking if any of these new lists
# is safe, using the approach of the first part. This means repeating the first
# part up to N times per list, which is not very efficient.
#
# If we know what levels are (or might be) causing the list to be unsafe, we can
# instead try removing only those levels. For example, if the difference at index
# i is larger than three, we only have to try removing the levels at indices i and
# i-1; either one of these removals makes the list safe – in which case we count
# the list – or the list remains unsafe. Either way, we only have to perform
# this check for the first invalid difference, so in principle we only have
# to removing two different levels.
#
# To find the first invalid difference, we check the if the absolute value is zero
# or larger than three, and if its sign differs from the sign of the first difference.
# This last part creates an edge-case if the sign of the first difference itself is
# wrong (e.g. the first difference is positive but all others are negative), so to
# cover this edge-case we also try removing the levels around index zero, i.e. the
# first and second levels. There are smarter ways to deal with (or avoid) this
# edge-case without increasing the number of checks we have to perform, but
# these extra checks do not significantly impact run-time in practice.
#
# While we conceptually delete levels, we do not actually have to modify the input
# levels list and recompute the differences; instead, we can adjust the differences
# list by summing up two adjacent elements. For example, if the differences list is
# [a, b, c, d] and c is the invalid element, we recombine the list into [a, b+c, d]
# and [a, b, c+d], and check if either is safe; this corresponds to deleting levels
# at index 2 and 3, respectively, and recomputing the differences. We use Enum.split/2
# to split the differences list, and sum_first_two/1 to sum up the two elements of the
# tail part before recombining it with the head part.

defmodule Solutions.Day02.PartB do
  def solve(lines) do
    lines
    |> Stream.map(&parse_line/1)
    |> Stream.map(&compute_diffs/1)
    |> Stream.filter(&is_safe/1)
    |> Enum.count()
  end

  defp is_safe(diffs), do: is_safe_diffs(diffs) or can_be_made_safe(diffs)

  defp can_be_made_safe(diffs) do
    invalid_index = find_first_invalid_index(diffs, hd(diffs))
    recombined_is_safe(diffs, invalid_index) or recombined_is_safe(diffs, 0)
  end

  defp recombined_is_safe(diffs, invalid_index) do
    is_safe_diffs(merge_diffs_at(diffs, invalid_index)) or
      is_safe_diffs(merge_diffs_at(diffs, invalid_index + 1))
  end

  # Find the index of the first difference value that is larger than
  # three or that has a sign different from the input sign, or nil if
  # no such difference value exists (i.e. the list is safe).

  defp find_first_invalid_index(diffs, sign),
    do: diffs |> Enum.find_index(fn d -> abs(d) > 3 or d * sign <= 0 end)

  # Merge the difference values at i and i-1 by replacing them both with
  # their sum, returning a new list one element shorter than the input list.
  # If i is zero, instead drop the first difference; this corresponds to
  # deleting the first level value. Similarly, if i is equal to the list
  # length, we effectively drop the last difference value.

  defp merge_diffs_at([_ | tail], 0), do: tail

  defp merge_diffs_at(diffs, i) do
    {head, tail} = Enum.split(diffs, i - 1)
    head ++ sum_first_two(tail)
  end

  # Compute the sum of the first two elements and concatenate it with the
  # tail, or return an empty list if the input size is less than two; this
  # covers the edge-case of deleting the last level value in the list.

  defp sum_first_two([a, b | tl]), do: [a + b | tl]
  defp sum_first_two(_), do: []
end
