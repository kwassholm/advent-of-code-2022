defmodule Day8 do
  defp prepare_data() do
    AoC.read_input("day_8.txt")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn x ->
      Enum.map(x, &String.to_integer/1)
    end)
  end

  defp get_tree_height(forest, x, y) do
    Enum.at(forest, y)
    |> Enum.at(x)
  end

  defp check_it(line, tree_height, i) do
    {b, [_ | e]} = Enum.split(line, i)

    case Enum.all?(Enum.map(b, &(&1 < tree_height))) do
      true -> true
      false -> Enum.all?(Enum.map(e, &(&1 < tree_height)))
    end
  end

  defp check_scenic(data, x, y, max_x, max_y, direction, target_tree_height, score \\ 1) do
    {n_x, n_y} =
      case direction do
        :top -> {x, y - 1}
        :right -> {x + 1, y}
        :down -> {x, y + 1}
        :left -> {x - 1, y}
      end

    cond do
      get_tree_height(data, n_x, n_y) < target_tree_height and n_y > 0 and n_x > 0 and
        n_y < max_y and
          n_x < max_x ->
        check_scenic(data, n_x, n_y, max_x, max_y, direction, target_tree_height, score + 1)

      true ->
        score
    end
  end

  defp parse_a(data) do
    columns = length(List.first(data))
    rows = length(data)

    Enum.map(
      1..(rows - 2),
      fn y ->
        Enum.map(1..(columns - 2), fn x ->
          tree_height = get_tree_height(data, x, y)

          with false <-
                 Enum.map(0..(rows - 1), &Enum.at(Enum.at(data, &1), x))
                 |> check_it(tree_height, y),
               false <-
                 Enum.map(0..(columns - 1), &Enum.at(Enum.at(data, y), &1))
                 |> check_it(tree_height, x) do
          end
        end)
      end
    )
    |> List.flatten()
    |> Enum.count(& &1)
    |> (&(columns * 2 + rows * 2 - 4 + &1)).()
  end

  defp parse_b(data) do
    columns = length(List.first(data))
    rows = length(data)

    Enum.map(
      1..(rows - 2),
      fn y ->
        Enum.map(1..(columns - 2), fn x ->
          Enum.reduce(
            [:top, :right, :down, :left],
            [],
            &[
              check_scenic(
                data,
                x,
                y,
                columns - 1,
                rows - 1,
                &1,
                get_tree_height(data, x, y)
              )
              | &2
            ]
          )
          |> Enum.product()
        end)
      end
    )
  end

  def execute_a() do
    prepare_data()
    |> parse_a()
    |> AoC.print_answer()
  end

  def execute_b() do
    prepare_data()
    |> parse_b()
    |> List.flatten()
    |> Enum.max()
    |> AoC.print_answer()
  end
end
