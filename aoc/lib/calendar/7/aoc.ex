defmodule XDir do
  defstruct [:name, :id, :parent_id, size: 0, files: []]
end

defmodule XFile do
  defstruct [:name, :size]
end

defmodule Day7 do
  defp prepare_data() do
    AoC.read_input("day_7.txt")
  end

  @types [
    {~r/\$ (cd (?<name>\/))/, :go_root},
    {~r/\$ (cd \.\.)/, :go_back},
    {~r/\$ (cd) (?<name>[^\n]+)/, :cd},
    {~r/\$ (ls)/, :ls},
    {~r/dir (?<name>[^\n]+)/, :dir},
    {~r/(?<size>[0-9]+) (?<name>[^\n]+)/, :file}
  ]

  defp type(x) do
    {regex, type} =
      Enum.find(@types, fn {regex, _} ->
        String.match?(x, regex)
      end)

    {regex, type}
  end

  def size_to_integer(%{"size" => size} = result) do
    Map.put(result, "size", String.to_integer(size))
  end

  def size_to_integer(result), do: result

  defp parse_row(row) do
    {regex, type} = type(row)

    result =
      Regex.named_captures(regex, row)
      |> Map.put("type", type)
      |> size_to_integer()

    for {k, v} <- result, into: %{} do
      {String.to_atom(k), v}
    end
  end

  defp create_id() do
    System.unique_integer([:positive])
  end

  defp find_dir_by_id(dirs, default \\ nil, id) do
    Enum.find(dirs, default, &(&1.id == id))
  end

  defp find_dir_index_by_id(dirs, id) do
    Enum.find_index(dirs, &(&1.id == id))
  end

  def replace_dir_in_acc(acc, dir) do
    i = Enum.find_index(acc, &(&1.id == dir.id))

    case i do
      nil -> [dir | acc]
      _ -> List.replace_at(acc, i, dir)
    end
  end

  defp calculate_size(%{fs: fs}) do
    Enum.reduce_while(fs, [], fn x, acc ->
      x = find_dir_by_id(acc, x, x.id)
      total_size = Enum.sum(get_in(x.files, [Access.all(), :size]))
      {_, x} = Map.get_and_update(x, :size, &{&1, &1 + total_size})

      case find_dir_by_id(fs, x.parent_id) do
        nil ->
          {:cont, List.replace_at(acc, find_dir_index_by_id(acc, x.id), x)}

        _ ->
          acc =
            Stream.unfold(x.parent_id, fn
              nil ->
                nil

              id ->
                {id, find_dir_by_id(fs, id).parent_id}
            end)
            |> Stream.map(fn x ->
              {_, dir} =
                Map.get_and_update(
                  find_dir_by_id(acc, find_dir_by_id(fs, x), x),
                  :size,
                  &{&1, &1 + total_size}
                )

              dir
            end)
            |> Enum.reduce(acc, fn x, cca ->
              replace_dir_in_acc(cca, x)
            end)
            |> replace_dir_in_acc(x)

          {:cont, acc}
      end
    end)
  end

  defp parse(data) do
    result =
      Enum.reduce(data, %{fs: [], cur_dir: %{}, prev_cmd: nil}, fn row,
                                                                   %{
                                                                     fs: fs,
                                                                     cur_dir: cur_dir,
                                                                     prev_cmd: prev_cmd
                                                                   } ->
        result =
          parse_row(row)
          |> Map.put(:prev_cmd, prev_cmd)

        case result do
          %{type: :go_back} ->
            fs = if prev_cmd == :go_back, do: fs, else: [cur_dir | fs]

            %{
              fs: fs,
              cur_dir: find_dir_by_id(fs, cur_dir.parent_id),
              prev_cmd: :go_back
            }

          %{type: :go_root} ->
            %{
              fs: fs,
              cur_dir: %XDir{
                name: result.name,
                id: create_id(),
                parent_id: nil
              },
              prev_cmd: :go_root
            }

          %{type: :cd, prev_cmd: :go_back} ->
            %{
              fs: fs,
              cur_dir: %XDir{
                name: result.name,
                id: create_id(),
                parent_id: cur_dir.id
              },
              prev_cmd: :cd
            }

          %{type: :cd} ->
            %{
              fs: [cur_dir | fs],
              cur_dir: %XDir{
                name: result.name,
                id: create_id(),
                parent_id: cur_dir.id
              },
              prev_cmd: :cd
            }

          %{type: :file} ->
            {_, cur_dir} = get_and_update_in(cur_dir.files, &{&1, [result | &1]})
            %{fs: fs, cur_dir: cur_dir, prev_cmd: :ls}

          %{:type => type} ->
            %{fs: fs, cur_dir: cur_dir, prev_cmd: type}
        end
      end)

    {_, result} = get_and_update_in(result.fs, &{&1, [result.cur_dir | &1]})
    result
  end

  def execute_a() do
    prepare_data()
    |> parse()
    |> calculate_size
    |> Enum.filter(&(&1.size <= 100_000))
    |> Enum.map(& &1.size)
    |> Enum.sum()
    |> AoC.print_answer()
  end

  def execute_b() do
    result =
      prepare_data()
      |> parse()
      |> calculate_size

    fs_max_space = 70_000_000
    needed_space = 30_000_000 - (fs_max_space - Enum.find(result, &(&1.parent_id == nil)).size)

    Enum.filter(result, &(&1.size > needed_space))
    |> Enum.min_by(& &1.size)
    |> Map.get(:size)
    |> AoC.print_answer()
  end
end
