defmodule Day5 do
  defp prepare_data() do
    AoC.read_raw_input("day_5.txt")
  end

  def do_reverse_or_maybe_not(items, %{:do_reverse => true}) do
    Enum.reverse(items)
  end

  def do_reverse_or_maybe_not(items, %{:do_reverse => false}) do
    items
  end

  def execute_a(lazy_reverse_or_not \\ %{:do_reverse => true}) do
    [init_stacks, _, instructions] =
      prepare_data()
      |> Enum.chunk_by(fn x ->
        x == "\n"
      end)

    stacks =
      List.delete_at(init_stacks, -1)
      |> Enum.map(fn x ->
        String.codepoints(x)
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.at(&1, 1))
      end)
      |> List.zip()
      |> Enum.map(fn x ->
        Enum.filter(Tuple.to_list(x), &(&1 != " "))
      end)

    {_, result} =
      Enum.map_reduce(instructions, stacks, fn x, stacks ->
        [move, from, to] =
          Regex.scan(~r/(\d)+/, x, capture: :first)
          |> Enum.flat_map(fn x ->
            [String.to_integer(List.to_string(x))]
          end)

        from = from - 1
        to = to - 1

        source_stack = Enum.at(stacks, from)

        moved_items =
          Enum.slice(source_stack, 0, move)
          |> do_reverse_or_maybe_not(lazy_reverse_or_not)

        stacks = List.replace_at(stacks, from, Enum.drop(source_stack, move))
        stacks = List.replace_at(stacks, to, moved_items ++ Enum.at(stacks, to))

        {:ok, stacks}
      end)

    Enum.map(result, &Enum.at(&1, 0))
    |> List.to_string()
    |> AoC.print_answer()
  end

  def execute_b() do
    execute_a(%{:do_reverse => false})
  end
end
