defmodule Solutions.Day19.Common do
  def parse([towels | [_ | patterns]]) do
    {parse_towels(towels), patterns}
  end

  defp parse_towels(towels_line) do
    towels_line
    |> String.split(", ")
    |> Enum.map(fn towel -> {towel, String.length(towel)} end)
    |> Enum.sort_by(fn {_, length} -> length end, :asc)
  end

  def get_pattern_chunks(patterns) do
    chunk_count = System.schedulers_online() * 4
    chunk_size = max(div(length(patterns), chunk_count), 1)
    Enum.chunk_every(patterns, chunk_size)
  end
end
