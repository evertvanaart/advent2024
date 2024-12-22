import Solutions.Day22.Common

# For this first part, we simply calculate the 2000th value for each line
# using a recursive function, and calculate their sum. I don't think there
# is a way to do this more efficiently (e.g. a way to immediately compute
# the value after X steps without doing the intermediate steps), although
# admittedly I did not look very hard. Using an asynchronous stream, this
# solution runs in just over 10 milliseconds, so it's fast enough.

defmodule Solutions.Day22.PartA do
  def solve(lines) do
    get_line_chunks(lines)
    |> Task.async_stream(fn lines ->
      lines
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&solve_value/1)
      |> Enum.sum()
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp solve_value(value) do
    recurse(value, 2000)
  end

  defp recurse(value, 0), do: value

  defp recurse(value, step) do
    value = mix_prune(value, value * 64)
    value = mix_prune(value, div(value, 32))
    value = mix_prune(value, value * 2048)
    recurse(value, step - 1)
  end
end
