defmodule Solutions.Day07.Common do
  def parse(line) do
    [lh, rh] = String.split(line, ": ", parts: 2)
    fields = String.split(rh) |> Enum.map(&String.to_integer/1)
    {String.to_integer(lh), fields}
  end
end
