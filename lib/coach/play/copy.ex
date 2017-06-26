defmodule Coach.Play.Copy do
  alias Coach.Cmd

  @spec cmd(Path.t, Path.t) :: Cmd.t
  def cmd(from, to) do
    Cmd.from_function(File, :cp, [from, to])
  end
end

