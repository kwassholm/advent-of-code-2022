defmodule Day4 do
  def prepare_data() do
    AoC.read_input("day_4.txt")
  end

  defp is_subsetting(range_1, range_2) do
    [MapSet.subset?(range_1, range_2), MapSet.subset?(range_2, range_1)]
  end

  defp is_disjointing(range_1, range_2) do
    [MapSet.disjoint?(range_1, range_2), MapSet.disjoint?(range_2, range_1)]
  end

  defp get_ranges(x) do
    ranges =
      String.split(x, ",")
      |> Enum.map(fn pair ->
        String.split(pair, "-")
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(&Range.new(Enum.at(&1, 0), Enum.at(&1, 1)))

    [
      MapSet.new(Enum.at(ranges, 0)),
      MapSet.new(Enum.at(ranges, 1))
    ]
  end

  def execute_a() do
    prepare_data()
    |> Enum.map(&get_ranges/1)
    |> Enum.map(fn [range_1, range_2] ->
      is_subsetting(range_1, range_2)
    end)
    |> Enum.count(&Enum.member?(&1, true))
    |> AoC.print_answer()
  end

  def execute_b() do
    prepare_data()
    |> Enum.map(&get_ranges/1)
    |> Enum.map(fn [range_1, range_2] ->
      is_disjointing(range_1, range_2)
    end)
    |> Enum.count(&Enum.member?(&1, false))
    |> AoC.print_answer()
  end
end
