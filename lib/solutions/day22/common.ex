defmodule Solutions.Day22.Common do
  def get_line_chunks(lines) do
    chunk_count = System.schedulers_online() * 4
    chunk_size = max(div(length(lines), chunk_count), 1)
    Enum.chunk_every(lines, chunk_size)
  end

  def mix_prune(a, b), do: Integer.mod(Bitwise.bxor(a, b), 16_777_216)
end
