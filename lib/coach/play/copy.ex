defmodule Coach.Play.Copy do
  alias Coach.Cmd.Function

  @spec cmd(Path.t, Path.t) :: Cmd.t
  def cmd(from, to) do
    Function.from_function(File, :cp, [from, to])
  end
end

