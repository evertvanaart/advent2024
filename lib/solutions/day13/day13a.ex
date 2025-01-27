import Solutions.Day13.Common

# If we define p = {p.x, p.y} as the prize position, da and db as the step
# vectors for buttons A and B, and na and nb as the number of times we
# press these buttons, we can state that:
#
#   p = na * da + nb * db
#   p - na * da = nb * db
#   nb = (p - na * da) / db
#
# Since we know that na is at most 100, we can simply try finding a matching
# value nb for all values of na. We first check if such a value can exist in
# one dimension (i.e. p.x - na * da.x must be divisible by db.x), then check
# if that potential nb value is also valid for the other dimension. This
# gives us all valid combinations of na and nb, and we can calculate the
# cost for each combination and take the minimum.

defmodule Solutions.Day13.PartA do
  def solve(lines) do
    machines = parse(lines)

    machines
    |> Enum.map(fn machine ->
      0..100
      |> Enum.map(fn na -> {na, calculate_nb(machine, na)} end)
      |> Enum.filter(fn {_, nb} -> nb != nil end)
      |> Enum.map(&calculate_cost/1)
      |> Enum.min(fn -> 0 end)
    end)
    |> Enum.sum()
  end

  defp calculate_nb({{dax, day}, {dbx, dby}, {px, py}}, na) do
    if rem(px - na * dax, dbx) == 0 do
      nb = div(px - na * dax, dbx)
      valid = py - na * day == nb * dby
      if valid, do: nb, else: nil
    else
      nil
    end
  end
end
