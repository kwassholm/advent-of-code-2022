defmodule AoC do
  def read_input(filename) do
    File.stream!("#{:code.priv_dir(:aoc)}/input/#{filename}")
    |> Enum.map(&String.trim(&1))
  end

  def read_input_as_ints(filename) do
    read_input(filename)
    |> Enum.map(fn
      x when x == "" -> x
      x -> String.to_integer(x)
    end)
  end

  def print_answer(answer) do
    IO.puts("Answer: #{answer}")
  end
end
