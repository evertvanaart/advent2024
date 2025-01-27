import Solutions.Day03.Common

# This can easily be solved using regular expressions. We use Regex.scan/3
# to find all exact matches of "mul(a,b)", where a and b both contain only
# decimal characters (i.e. "\d+"), then for each match convert the two
# matched groups to integers and compute their product.

defmodule Solutions.Day03.PartA do
  def solve(lines) do
    process_mul(Enum.join(lines))
  end
end
