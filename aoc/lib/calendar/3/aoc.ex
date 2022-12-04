defmodule Day3 do
  def prepare_data() do
    AoC.read_input("day_3.txt")
  end

  def priorities() do
    Map.new(
      Enum.zip(
        String.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "", trim: true),
        1..52
      )
    )
  end

  def split(x) do
    String.split(x, "", trim: true)
  end

  def execute_a() do
    prepare_data()
    |> Enum.reduce(0, fn x, sum ->
      {a, b} = String.split_at(x, trunc(String.length(x) / 2))

      l =
        MapSet.intersection(
          MapSet.new(split(a)),
          MapSet.new(split(b))
        )
        |> MapSet.to_list()
        |> List.to_string()

      sum + Map.get(priorities(), l)
    end)
    |> AoC.print_answer()
  end

  def execute_b() do
    prepare_data()
    |> Enum.chunk_every(3)
    |> Enum.reduce(0, fn [a, b, c], sum ->
      l =
        MapSet.intersection(MapSet.new(split(a)), MapSet.new(split(b)))
        |> MapSet.intersection(MapSet.new(split(c)))
        |> MapSet.to_list()
        |> List.to_string()

      sum + Map.get(priorities(), l)
    end)
    |> IO.inspect()
  end
end
