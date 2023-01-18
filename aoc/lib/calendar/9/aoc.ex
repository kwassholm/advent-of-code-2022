defmodule C do
  defstruct x: 0, y: 0, s: "", v: []
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

  defp draw_map_a(map, head, tail) do
    traverse(map, head, "H")
    |> traverse(tail, "T")
    |> Enum.reverse()
    |> IO.inspect()
  end

  defp draw_map_b(result, map) do
    Enum.reduce(result, map, &traverse(&2, &1, &1.s))
    |> Enum.reverse()
    |> IO.inspect()
  end

  def create_empty_map(columns, rows) do
    List.duplicate(List.duplicate(".", columns + 1), rows + 1)
  end

  defp travel({steps, _}) do
    max_x = Enum.max_by(steps, & &1.x)
    min_x = Enum.min_by(steps, & &1.x)
    max_y = Enum.max_by(steps, & &1.y)
    min_y = Enum.min_by(steps, & &1.y)
    columns = max_x.x + abs(min_x.x)
    rows = max_y.y + abs(min_y.y)
    empty_map = create_empty_map(columns, rows)

    Enum.reduce(
      steps,
      %{
        head: %C{},
        tail: %C{},
        tail_visited: []
      },
      fn step,
         %{
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

        # draw_map_a(empty_map, head, tail)

        %{head: head, tail: tail, tail_visited: tail_visited}
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

  defp update_travelled_points(knot) do
    %{knot | v: [%{x: knot.x, y: knot.y} | knot.v]}
  end

  defp do_it_better_this_time({steps, _}) do
    max_x = Enum.max_by(steps, & &1.x)
    min_x = Enum.min_by(steps, & &1.x)
    max_y = Enum.max_by(steps, & &1.y)
    min_y = Enum.min_by(steps, & &1.y)
    columns = max_x.x + abs(min_x.x)
    rows = max_y.y + abs(min_y.y)
    empty_map = create_empty_map(columns, rows)

    Enum.reduce(
      steps,
      %{
        knots: [
          %C{s: "1"},
          %C{s: "2"},
          %C{s: "3"},
          %C{s: "4"},
          %C{s: "5"},
          %C{s: "6"},
          %C{s: "7"},
          %C{s: "8"},
          %C{s: "9"}
        ]
      },
      fn step,
         %{
           knots: knots
         } ->
        head = %C{x: step.x, y: step.y, s: "H"}

        result =
          Enum.reduce(knots, [head], fn tail, acc ->
            prev_head = List.first(acc)

            tail =
              cond do
                max(abs(prev_head.x - tail.x), abs(prev_head.y - tail.y)) > 1 ->
                  cond do
                    prev_head.x == tail.x and prev_head.y - tail.y > 0 ->
                      %{
                        tail
                        | x: tail.x,
                          y: tail.y + 1
                      }

                    prev_head.x - tail.x > 0 and prev_head.y - tail.y > 0 ->
                      %{
                        tail
                        | x: tail.x + 1,
                          y: tail.y + 1
                      }

                    prev_head.x - tail.x > 0 and prev_head.y == tail.y ->
                      %{
                        tail
                        | x: tail.x + 1,
                          y: tail.y
                      }

                    prev_head.x - tail.x < 0 and prev_head.y - tail.y < 0 ->
                      %{
                        tail
                        | x: tail.x - 1,
                          y: tail.y - 1
                      }

                    prev_head.x == tail.x and prev_head.y - tail.y < 0 ->
                      %{
                        tail
                        | x: tail.x,
                          y: tail.y - 1
                      }

                    prev_head.x - tail.x > 0 and prev_head.y - tail.y < 0 ->
                      %{
                        tail
                        | x: tail.x + 1,
                          y: tail.y - 1
                      }

                    prev_head.x - tail.x < -1 and prev_head.y == tail.y ->
                      %{
                        tail
                        | x: tail.x - 1,
                          y: tail.y
                      }

                    prev_head.x - tail.x < 0 and prev_head.y - tail.y > 0 ->
                      %{
                        tail
                        | x: tail.x - 1,
                          y: tail.y + 1
                      }

                    true ->
                      tail
                  end

                true ->
                  tail
              end
              |> update_travelled_points()

            [tail | acc]
          end)

        # draw_map_b(result, empty_map)

        result = Enum.reverse(result)
        [_ | knots] = result

        %{knots: knots}
      end
    )
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

  def execute_b() do
    prepare_data()
    |> parse_steps()
    |> head_path()
    |> do_it_better_this_time()
    |> Map.get(:knots)
    |> Enum.find(&(Map.get(&1, :s) == "9"))
    |> Map.get(:v)
    |> Enum.uniq()
    |> Enum.count()
    |> AoC.print_answer()
  end
end
