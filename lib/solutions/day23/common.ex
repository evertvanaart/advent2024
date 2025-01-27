defmodule Solutions.Day23.Common do
  @min_chunk_size 100

  def get_chunks(list) do
    chunk_count = System.schedulers_online() * 4
    chunk_size = max(div(length(list), chunk_count), 1)
    chunk_size = max(chunk_size, @min_chunk_size)
    Enum.chunk_every(list, chunk_size)
  end

  def parse([], map), do: map

  def parse([head | tail], map) do
    [a, b] = String.split(head, "-")
    map = Map.update(map, a, MapSet.new([b]), &MapSet.put(&1, b))
    map = Map.update(map, b, MapSet.new([a]), &MapSet.put(&1, a))
    parse(tail, map)
  end
end
