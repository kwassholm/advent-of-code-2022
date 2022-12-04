defmodule Day2 do
  def prepare_data() do
    AoC.read_input("day_2.txt")
  end

  def execute_a() do
    rock_x = 1
    paper_y = 2
    scissors_z = 3

    lost = 0
    draw = 3
    won = 6

    prepare_data()
    |> Enum.reduce(0, fn
      x, score ->
        case String.split(x) do
          ["A", "X"] ->
            score + rock_x + draw

          ["A", "Y"] ->
            score + paper_y + won

          ["A", "Z"] ->
            score + scissors_z + lost

          ["B", "X"] ->
            score + rock_x + lost

          ["B", "Y"] ->
            score + paper_y + draw

          ["B", "Z"] ->
            score + scissors_z + won

          ["C", "X"] ->
            score + rock_x + won

          ["C", "Y"] ->
            score + paper_y + lost

          ["C", "Z"] ->
            score + scissors_z + draw
        end
    end)
    |> AoC.print_answer()
  end

  def response_index(x) when x < 0, do: 2
  def response_index(x) when x > 2, do: 0
  def response_index(x), do: x

  def response_score(oppo, strategy) do
    case strategy do
      :draw -> oppo
      :won -> response_index(oppo + 1)
      :lost -> response_index(oppo - 1)
    end
  end

  def execute_b() do
    strategies = %{
      X: :lost,
      Y: :draw,
      Z: :won
    }

    shapes = %{
      A: :rock,
      B: :paper,
      C: :scissors
    }

    result_score = %{
      lost: 0,
      draw: 3,
      won: 6
    }

    shape_score = %{
      :rock => 1,
      :paper => 2,
      :scissors => 3
    }

    shape_to_index_map = %{
      :rock => 0,
      :paper => 1,
      :scissors => 2
    }

    index_to_shape_map = Map.new(shape_to_index_map, fn {k, v} -> {v, k} end)

    prepare_data()
    |> Enum.reduce(0, fn
      x, score ->
        case String.split(x) do
          [a, b] ->
            opponent_shape = Map.get(shapes, String.to_atom(a))
            strategy = Map.get(strategies, String.to_atom(b))

            response_shape =
              Map.get(
                index_to_shape_map,
                response_score(Map.get(shape_to_index_map, opponent_shape), strategy)
              )

            score + Map.get(result_score, strategy) + Map.get(shape_score, response_shape)
        end
    end)
    |> AoC.print_answer()
  end
end
