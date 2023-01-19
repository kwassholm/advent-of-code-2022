defmodule Day10 do
  defp prepare_data() do
    AoC.read_input("day_10.txt")
  end

  defp parse(data) do
    List.foldl(data, %{next_x: 1, cycle: 0, signals: []}, fn instr,
                                                             %{
                                                               next_x: prev_x,
                                                               cycle: cycle,
                                                               signals: signals
                                                             } ->
      cycle = cycle + 1

      result =
        case String.split(instr, " ") do
          [_] ->
            [%{cycle: cycle, signal: cycle * prev_x, next_x: prev_x}]

          [_, value] ->
            cycle2 = cycle + 1

            [
              %{cycle: cycle, signal: cycle * prev_x},
              %{
                cycle: cycle2,
                signal: cycle2 * prev_x,
                next_x: Enum.sum([prev_x, String.to_integer(value)])
              }
            ]
        end

      r = List.last(result)

      %{next_x: r.next_x, cycle: r.cycle, signals: signals ++ result}
    end)
  end

  def execute_a() do
    prepare_data()
    |> parse()
    |> Map.get(:signals)
    |> Enum.filter(&Enum.member?([20, 60, 100, 140, 180, 220], &1.cycle))
    |> List.foldl(0, &(&1.signal + &2))
    |> AoC.print_answer()
  end
end
