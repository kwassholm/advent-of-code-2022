defmodule Mix.Tasks.DoIt do
  def run(args) do
    [day, part] = String.split(List.to_string(args))
    apply(String.to_existing_atom("Elixir.Day#{day}"), String.to_atom("execute_#{part}"), [])
  end
end
