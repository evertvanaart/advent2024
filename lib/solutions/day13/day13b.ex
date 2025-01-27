import Solutions.Day13.Common

# I'm really bad with these sorts of math questions, so this took a while
# to figure out. Using the equations from the first part, we know that:
#
#   nb = (p.x - na * da.x) / db.x
#   nb = (p.y - na * da.y) / db.y
#
# Both are linear equations for na, and we are looking for values na and
# nb that satisfy both equations; in other words, the right-hand sides of
# both equations should be equal, allowing us to rewrite them as follows:
#
#   (p.x - na * da.x) / db.x = (p.y - na * d.ay) / db.y
#   db.y * (p.x - na * da.x) = db.x * (py - na * da.y)
#   na * db.x * da.y - na * da.x * db.y = db.x * p.y - db.y * p.x
#   na = (db.x * p.y - db.y * p.x) / (db.x * da.y - da.x * db.y)
#
# This means that we can find a valid na using the known values of p, da,
# and db; this division has to produce an integer (i.e. the remainder has
# to be zero) for this to correspond to a valid number of button pressed.
# Once we've found na in this way, we can easily derive nb using either
# of the first two equations.
#
# This produces only one possible combination of na and nb though, and its
# cost will not necessarily be minimal. To this end, we also calculate nb
# and then derive na – using the exact same equations, just swapping a and
# b everywhere – and then check which cost is lower. I'm honestly still
# not 100% sure if the mathematical reasoning here is sound, but this
# does produce the correct answer, and it's very fast to boot.

defmodule Solutions.Day13.PartB do
  @offset 10_000_000_000_000

  def solve(lines) do
    machines = parse(lines)
    machines = add_offsets(machines)

    costs_nb =
      machines
      |> Enum.map(fn machine -> {machine, calculate_nb(machine)} end)
      |> Enum.map(fn {machine, nb} -> {derive_na(machine, nb), nb} end)
      |> Enum.map(&calculate_cost/1)

    costs_na =
      machines
      |> Enum.map(fn machine -> {machine, calculate_na(machine)} end)
      |> Enum.map(fn {machine, na} -> {na, derive_nb(machine, na)} end)
      |> Enum.map(&calculate_cost/1)

    Enum.zip(costs_nb, costs_na)
    |> Enum.map(&get_minimum/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.sum()
  end

  defp calculate_na({{dax, day}, {dbx, dby}, {px, py}}) do
    dividend = dbx * py - dby * px
    divisor = dbx * day - dax * dby
    divide(dividend, divisor)
  end

  defp calculate_nb({{dax, day}, {dbx, dby}, {px, py}}) do
    dividend = dax * py - day * px
    divisor = dax * dby - dbx * day
    divide(dividend, divisor)
  end

  defp divide(dividend, divisor) do
    case rem(dividend, divisor) do
      0 -> div(dividend, divisor)
      _ -> nil
    end
  end

  defp derive_nb(_, nil), do: nil
  defp derive_nb({{dax, _}, {dbx, _}, {px, _}}, na), do: div(px - na * dax, dbx)

  defp derive_na(_, nil), do: nil
  defp derive_na({{dax, _}, {dbx, _}, {px, _}}, nb), do: div(px - nb * dbx, dax)

  defp get_minimum({nil, nil}), do: nil
  defp get_minimum({_, nil}), do: nil
  defp get_minimum({nil, _}), do: nil
  defp get_minimum({a, b}), do: min(a, b)

  defp add_offsets(machines), do: Enum.map(machines, fn {a, b, p} -> {a, b, add_offset(p)} end)
  defp add_offset({px, py}), do: {px + @offset, py + @offset}
end
