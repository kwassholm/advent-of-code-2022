defmodule Day1 do
  def prepare_data() do
    AoC.read_input_as_ints("day_1.txt")
    |> Enum.chunk_while(
      [],
      fn
        element, chunk when element != "" ->
          {:cont, [element | chunk]}

        _, chunk ->
          {:cont, Enum.sum(chunk), []}
      end,
      fn
        [] ->
          {:cont, []}

        acc ->
          {:cont, Enum.sum(acc), []}
      end
    )
  end

  def execute_a() do
    prepare_data()
    |> Enum.max()
    |> AoC.print_answer()
  end

  def execute_b() do
    prepare_data()
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.sum()
    |> AoC.print_answer()
  end
end
