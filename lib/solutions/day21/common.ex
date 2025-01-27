defmodule Solutions.Day21.Common do
  def get_numeric(line), do: String.replace(line, "A", "") |> String.to_integer()

  def to_key("A"), do: :a
  def to_key("0"), do: :n0
  def to_key("1"), do: :n1
  def to_key("2"), do: :n2
  def to_key("3"), do: :n3
  def to_key("4"), do: :n4
  def to_key("5"), do: :n5
  def to_key("6"), do: :n6
  def to_key("7"), do: :n7
  def to_key("8"), do: :n8
  def to_key("9"), do: :n9
end
