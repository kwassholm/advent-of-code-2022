defmodule Day6 do
  defp prepare_data() do
    AoC.read_input("day_6.txt")
  end

  def do_it(marker_length) do
    prepare_data()
    |> List.to_string()
    |> String.graphemes()
    |> Enum.reduce_while([], fn x, acc ->
      acc = [x | acc]

      count =
        Enum.slice(acc, 0..(marker_length - 1))
        |> Enum.uniq()
        |> Enum.count()

      if count == marker_length do
        {:halt, Enum.count(acc)}
      else
        {:cont, acc}
      end
    end)
  end

  def execute_a() do
    do_it(4)
    |> AoC.print_answer()
  end

  def execute_b() do
    do_it(14)
    |> AoC.print_answer()
  end
end
