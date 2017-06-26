defmodule Coach.Playbook do
  defmacro __using__(_) do
    quote do
      import Coach.Playbook
      alias Coach.Cmd
      alias Coach.Cmd.Combinator
    end
  end
end
