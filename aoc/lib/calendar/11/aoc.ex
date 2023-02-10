defmodule Monkey do
  use Agent

  def start_link(initial) do
    Agent.start_link(fn -> initial end,
      name:
        String.replace(initial.name, " ", "")
        |> String.downcase()
        |> String.to_atom()
    )
  end

  def name(monkey) do
    Agent.get(monkey, & &1.name)
  end

  def items(monkey) do
    Agent.get(monkey, & &1.items)
  end

  def inspections(monkey) do
    Agent.get(monkey, & &1.inspections)
  end

  def unpocket_items(monkey) do
    Agent.get_and_update(monkey, fn spec ->
      Map.get_and_update(spec, :items, &{&1, []})
    end)
  end

  def test_value(monkey) do
    Agent.get(monkey, & &1.test)
  end

  def calming_method_a(worry_level) do
    Integer.floor_div(worry_level, 3)
  end

  def calming_method_b(worry_level) do
    # Too lazy to programmatically get the value,
    # which is the product of all of the monkeys test values.
    Integer.mod(worry_level, 9_699_690)
  end

  def inspect_item(monkey, item, calming_method) do
    {worry_level, _} =
      Agent.get(monkey, & &1.operations)
      |> Code.eval_string(old: item)

    Agent.get_and_update(monkey, fn spec ->
      Map.get_and_update(spec, :inspections, &{&1, &1 + 1})
    end)

    calming_method.(worry_level)
  end

  def decide_target(monkey, item) do
    test = Agent.get(monkey, & &1.test)

    case Integer.mod(item, test) do
      0 -> Agent.get(monkey, & &1.test_true)
      _ -> Agent.get(monkey, & &1.test_false)
    end
  end

  def throw_item({_, monkey}, item) do
    Agent.update(monkey, fn spec ->
      Map.update!(spec, :items, &(&1 ++ [item]))
    end)
  end
end

defmodule Day11 do
  use Agent

  defp prepare_data() do
    AoC.read_input("day_11.txt")
  end

  defp value_to_integer(map, key, value) do
    Map.put(
      map,
      key,
      value
      |> Access.get(key)
      |> String.to_integer()
    )
  end

  defp parse_monkeys(data) do
    Enum.chunk_every(data, 7)
    |> Enum.map(fn x ->
      monkey_data = Regex.named_captures(~r/(?<name>[^:]+)/, Enum.at(x, 0))

      monkey_data =
        Map.put(
          monkey_data,
          "items",
          String.split(Enum.at(String.split(Enum.at(x, 1), ": "), 1), ", ")
          |> Enum.map(&String.to_integer(&1))
        )

      monkey_data =
        Map.merge(monkey_data, Regex.named_captures(~r/= (?<operations>.*)/, Enum.at(x, 2)))

      monkey_data =
        value_to_integer(
          monkey_data,
          "test",
          Regex.named_captures(~r/(?<test>\d+)/, Enum.at(x, 3))
        )

      monkey_data =
        value_to_integer(
          monkey_data,
          "test_true",
          Regex.named_captures(~r/(?<test_true>\d+)/, Enum.at(x, 4))
        )

      monkey_data =
        value_to_integer(
          monkey_data,
          "test_false",
          Regex.named_captures(~r/(?<test_false>\d+)/, Enum.at(x, 5))
        )

      for {k, v} <- monkey_data, into: %{} do
        {String.to_atom(k), v}
      end
      |> Map.put_new(:inspections, 0)
    end)
  end

  defp start_up_monkeys(monkey_spec) do
    Enum.map(monkey_spec, fn x ->
      Monkey.start_link(x)
    end)
  end

  defp play_it(monkeys, rounds, calming_method) do
    Enum.each(1..rounds, fn _ ->
      Enum.map(monkeys, fn {_, monkey} ->
        Monkey.unpocket_items(monkey)
        |> Enum.map(fn item ->
          worry_level = Monkey.inspect_item(monkey, item, calming_method)
          target_monkey = Monkey.decide_target(monkey, worry_level)

          Enum.at(monkeys, target_monkey)
          |> Monkey.throw_item(worry_level)
        end)
      end)
    end)

    monkeys
  end

  def execute_a() do
    prepare_data()
    |> parse_monkeys()
    |> start_up_monkeys()
    |> play_it(20, &Monkey.calming_method_a/1)
    |> Enum.map(fn {_, monkey} ->
      Monkey.inspections(monkey)
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
    |> AoC.print_answer()
  end

  def execute_b() do
    prepare_data()
    |> parse_monkeys()
    |> start_up_monkeys()
    |> play_it(10000, &Monkey.calming_method_b/1)
    |> Enum.map(fn {_, monkey} ->
      Monkey.inspections(monkey)
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
    |> AoC.print_answer()
  end
end
