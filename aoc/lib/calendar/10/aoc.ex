defmodule Day10 do
  defp prepare_data() do
    AoC.read_input("day_10.txt")
  end

  defp parse(data) do
    List.foldl(data, %{x: 1, cycle: 0, signals: []}, fn instr,
                                                        %{
                                                          x: x,
                                                          cycle: cycle,
                                                          signals: signals
                                                        } ->
      cycle = cycle + 1

      result =
        case String.split(instr, " ") do
          [_] ->
            [%{cycle: cycle, signal: cycle * x, x: x, prev_x: x}]

          [_, value] ->
            cycle2 = cycle + 1

            [
              %{cycle: cycle, signal: cycle * x, x: x, prev_x: x},
              %{
                cycle: cycle2,
                signal: cycle2 * x,
                x: Enum.sum([x, String.to_integer(value)]),
                prev_x: x
              }
            ]
        end

      r = List.last(result)

      %{x: r.x, prev_x: r.prev_x, cycle: r.cycle, signals: signals ++ result}
    end)
  end

  defp draw_crt(data) do
    Enum.chunk_every(data, 40)
    |> Enum.map(fn row ->
      Enum.with_index(row, fn col, i ->
        sprite = [col.prev_x - 1, col.prev_x, col.prev_x + 1]

        cond do
          Enum.member?(sprite, i) -> IO.write("#")
          true -> IO.write(".")
        end
      end)

      IO.write("\n")
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

  def execute_b() do
    prepare_data()
    |> parse()
    |> Map.get(:signals)
    |> draw_crt()
  end
end
