defmodule Mix.Tasks.Coach.Run do
  use Mix.Task

  def run([module, play]) do
    Application.ensure_all_started(:coach)

    mod = get_module(module)
    func = String.to_atom(play) # Yes, I know.

    mod
    |> apply(func, [])
    |> Coach.Cmd.run
  end

  defp get_module(module_name) when is_binary(module_name) do
    uppercased =
      module_name
      |> String.first
      |> String.match?(~r/\p{Lu}/)

    if uppercased do
      :"Elixir.#{module_name}"
    else
      String.to_existing_atom(module_name)
    end
  end
end
