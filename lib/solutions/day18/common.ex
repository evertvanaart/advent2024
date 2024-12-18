defmodule Solutions.Day18.Common do
  # -------------------------------- Constants ------------------------------- #

  @neighbors [
    {1, 0},
    {0, 1},
    {-1, 0},
    {0, -1}
  ]

  # sample
  # @rows 7
  # @cols 7
  # @limit 12

  # input
  @rows 71
  @cols 71
  @limit 1024

  def get_target(), do: {@cols - 1, @rows - 1}
  def get_limit(), do: @limit

  # --------------------------------- Parsing -------------------------------- #

  def parse_line(line) do
    [x, y] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    {x, y}
  end

  # ---------------------------- Utility functions --------------------------- #

  def get_neighbors(p), do: Enum.map(@neighbors, &add_offset(p, &1))
  def add_offset({px, py}, {ox, oy}), do: {px + ox, py + oy}

  def in_grid({-1, _}), do: false
  def in_grid({_, -1}), do: false
  def in_grid({@cols, _}), do: false
  def in_grid({_, @cols}), do: false
  def in_grid({_, _}), do: true
end
