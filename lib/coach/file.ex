defmodule Coach.File do
  alias Coach.Cmd
  alias Coach.Cmd.{Function, Shell}

  @type file_type :: :dir | :file

  @spec ensure_deleted(Path.t) :: Cmd.t
  def ensure_deleted(path) do
    Function.from_function(fn ->
      if File.exists?(path) do
        Shell.new()
        |> Shell.with_command("rm")
        |> Shell.with_flag("-r")
        |> Shell.with_flag("-f")
        |> Shell.with_value(path)
        |> Cmd.run
      end
    end)
  end

  @spec ensure_exists(Path.t, file_type) :: Cmd.t
  def ensure_exists(path, :dir) do
    Function.from_function(fn ->
      unless File.exists?(path) do
        File.mkdir_p(path)
      end
    end)
  end
end
