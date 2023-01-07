defmodule C do
  defstruct x: 0, y: 0
end

defmodule Day9 do
  defp prepare_data() do
    AoC.read_input("day_9.txt")
  end

  defp parse_steps(data) do
    Enum.map(data, fn x ->
      [d, s] = String.split(x)
      s = String.to_integer(s)

      case d do
        "U" -> {:up, s}
        "R" -> {:right, s}
        "D" -> {:down, s}
        "L" -> {:left, s}
      end
    end)
  end

  defp travel({steps, _}) do
    max_x = Enum.max_by(steps, & &1.x)
    min_x = Enum.min_by(steps, & &1.x)
    max_y = Enum.max_by(steps, & &1.y)
    min_y = Enum.min_by(steps, & &1.y)
    columns = max_x.x + abs(min_x.x)
    rows = max_y.y + abs(min_y.y)
    empty_map = List.duplicate(List.duplicate(".", columns + 1), rows + 1)

    Enum.reduce(
      steps,
      %{
        map: empty_map,
        head: %C{},
        tail: %C{},
        tail_visited: []
      },
      fn step,
         %{
           map: map,
           head: prev_head,
           tail: tail,
           tail_visited: tail_visited
         } ->
        head = %C{x: step.x + abs(min_x.x), y: step.y + abs(min_y.y)}

        {tail, tail_visited} =
          cond do
            max(abs(head.x - tail.x), abs(head.y - tail.y)) > 1 ->
              {prev_head, [prev_head | tail_visited]}

            true ->
              {tail, tail_visited}
          end

        traverse(map, head, "H")
        |> traverse(tail, "T")

        # |> Enum.reverse()
        # |> IO.inspect()

        %{map: map, head: head, tail: tail, tail_visited: tail_visited}
      end
    )
  end

  defp traverse(acc, %{x: x, y: y}, sign) do
    List.replace_at(acc, y, List.replace_at(Enum.at(acc, y), x, sign))
  end

  defp head_path(steps) do
    Enum.flat_map_reduce(steps, %C{}, fn step, from ->
      case step do
        {:up, n} ->
          Enum.flat_map_reduce(1..n, from, fn _, from ->
            a = %C{x: from.x, y: from.y + 1}
            {[a], a}
          end)

        {:right, n} ->
          Enum.flat_map_reduce(1..n, from, fn _, from ->
            a = %C{x: from.x + 1, y: from.y}
            {[a], a}
          end)

        {:down, n} ->
          Enum.flat_map_reduce(1..n, from, fn _, from ->
            a = %C{x: from.x, y: from.y - 1}
            {[a], a}
          end)

        {:left, n} ->
          Enum.flat_map_reduce(1..n, from, fn _, from ->
            a = %C{x: from.x - 1, y: from.y}
            {[a], a}
          end)
      end
    end)
  end

  def execute_a() do
    prepare_data()
    |> parse_steps()
    |> head_path()
    |> travel()
    |> Map.get(:tail_visited)
    |> Enum.uniq()
    |> Enum.count()
    |> AoC.print_answer()
  end
end
