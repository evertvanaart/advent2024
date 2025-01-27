defmodule Advent2024 do
  @profile_run_count 20

  def main() do
    day_part = Enum.at(System.argv(), 0)
    input    = Enum.at(System.argv(), 1)
    profile  = Enum.at(System.argv(), 2) == "--profile"
    day      = String.slice(day_part, 0..-2//1)

    solver = get_solver(day_part)
    input  = get_input_filename(day, input)
    lines  = read_lines(input)

    case profile do
       true  -> run_profile(solver, lines)
       false -> run_once(solver, lines)
    end
  end

  defp run_once(solver, lines) do
    { time, result } = :timer.tc(solver, [lines])

    IO.puts("Finished in #{time} μs")
    IO.puts("Result: #{result}")
  end

  defp run_profile(solver, lines) do
    results = Enum.map(0 .. @profile_run_count, fn _ -> :timer.tc(solver, [lines]) end)
    times   = results |> Stream.drop(1) |> Enum.map(& elem(&1, 0))
    average = div(Enum.sum(times), length(times))

    IO.puts("Average time: #{average} μs")
  end

  defp read_lines(filename) do
    File.read!(filename) |> String.split("\n")
  end

  defp get_input_filename(day, input) do
    "lib/solutions/day#{day}/input/#{input}.txt"
  end

  defp get_solver(day_part) do
    case day_part do
      "01a" -> &Solutions.Day01.PartA.solve/1
      "01b" -> &Solutions.Day01.PartB.solve/1

      "02a" -> &Solutions.Day02.PartA.solve/1
      "02b" -> &Solutions.Day02.PartB.solve/1

      "03a" -> &Solutions.Day03.PartA.solve/1
      "03b" -> &Solutions.Day03.PartB.solve/1

      "04a" -> &Solutions.Day04.PartA.solve/1
      "04b" -> &Solutions.Day04.PartB.solve/1

      "05a" -> &Solutions.Day05.PartA.solve/1
      "05b" -> &Solutions.Day05.PartB.solve/1

      "06a" -> &Solutions.Day06.PartA.solve/1
      "06b" -> &Solutions.Day06.PartB.solve/1

      "07a" -> &Solutions.Day07.PartA.solve/1
      "07b" -> &Solutions.Day07.PartB.solve/1

      "08a" -> &Solutions.Day08.PartA.solve/1
      "08b" -> &Solutions.Day08.PartB.solve/1

      "09a" -> &Solutions.Day09.PartA.solve/1
      "09b" -> &Solutions.Day09.PartB.solve/1

      "10a" -> &Solutions.Day10.PartA.solve/1
      "10b" -> &Solutions.Day10.PartB.solve/1

      "11a" -> &Solutions.Day11.PartA.solve/1
      "11b" -> &Solutions.Day11.PartB.solve/1

      "12a" -> &Solutions.Day12.PartA.solve/1
      "12b" -> &Solutions.Day12.PartB.solve/1

      "13a" -> &Solutions.Day13.PartA.solve/1
      "13b" -> &Solutions.Day13.PartB.solve/1

      "14a" -> &Solutions.Day14.PartA.solve/1
      "14b" -> &Solutions.Day14.PartB.solve/1

      "15a" -> &Solutions.Day15.PartA.solve/1
      "15b" -> &Solutions.Day15.PartB.solve/1

      "16a" -> &Solutions.Day16.PartA.solve/1
      "16b" -> &Solutions.Day16.PartB.solve/1

      "17a" -> &Solutions.Day17.PartA.solve/1
      "17b" -> &Solutions.Day17.PartB.solve/1

      "18a" -> &Solutions.Day18.PartA.solve/1
      "18b" -> &Solutions.Day18.PartB.solve/1

      "19a" -> &Solutions.Day19.PartA.solve/1
      "19b" -> &Solutions.Day19.PartB.solve/1

      "20a" -> &Solutions.Day20.PartA.solve/1
      "20b" -> &Solutions.Day20.PartB.solve/1

      "21a" -> &Solutions.Day21.PartA.solve/1
      "21b" -> &Solutions.Day21.PartB.solve/1

      "22a" -> &Solutions.Day22.PartA.solve/1
      "22b" -> &Solutions.Day22.PartB.solve/1

      "23a" -> &Solutions.Day23.PartA.solve/1
      "23b" -> &Solutions.Day23.PartB.solve/1

      "24a" -> &Solutions.Day24.PartA.solve/1
      "24b" -> &Solutions.Day24.PartB.solve/1

      "25a" -> &Solutions.Day25.PartA.solve/1
    end
  end
end

Advent2024.main()
