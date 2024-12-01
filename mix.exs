defmodule Advent2024.MixProject do
  use Mix.Project

  def project do
    [
      escript: [main_module: Advent2024],
      app: :advent2024,
      version: "0.1.0",
      elixir: "~> 1.17",
      deps: deps()
    ]
  end

  defp deps, do: []
end
