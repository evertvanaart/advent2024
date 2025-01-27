defmodule Solutions.Day13.Common do
  # ---------------------------- Calculating costs --------------------------- #

  def calculate_cost({nil, nil}), do: nil
  def calculate_cost({na, nb}), do: 3 * na + nb

  # --------------------------------- Parsing -------------------------------- #

  @button_pattern ~r/Button .\: X\+(\d+), Y\+(\d+)/
  @prize_pattern ~r/Prize: X=(\d+), Y=(\d+)/

  def parse([]), do: []
  def parse(["" | tail]), do: parse(tail)

  def parse([button_a, button_b, prize | tail]) do
    matches_a = Regex.run(@button_pattern, button_a, capture: :all_but_first)
    matches_b = Regex.run(@button_pattern, button_b, capture: :all_but_first)
    matches_p = Regex.run(@prize_pattern, prize, capture: :all_but_first)

    machine = {
      convert(matches_a),
      convert(matches_b),
      convert(matches_p)
    }

    [machine | parse(tail)]
  end

  defp convert([x, y]), do: {String.to_integer(x), String.to_integer(y)}
end
