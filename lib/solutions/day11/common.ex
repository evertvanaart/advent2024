require Integer

defmodule Solutions.Day11.Common do
  def split(v) do
    digits = number_of_digits(v)
    divisor = 10 ** div(digits, 2)
    {div(v, divisor), Integer.mod(v, divisor)}
  end

  def is_even_digits(v), do: Integer.is_even(number_of_digits(v))
  def number_of_digits(v), do: floor(:math.log10(v)) + 1
end
