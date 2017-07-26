defmodule Coach.File do
  alias Coach.Cmd
  alias Coach.Cmd.{Function, Shell}

  @type file_type :: :dir | :file

  @spec ensure_deleted(Coach.Path.t) :: Cmd.t
  def ensure_deleted(path) do
    Function.from_function(fn ->
      file_path = Coach.Path.path(path)
      if File.exists?(file_path) do
        Shell.new()
        |> Shell.with_command("rm")
        |> Shell.with_flag("-r")
        |> Shell.with_flag("-f")
        |> Shell.with_value(file_path)
        |> Cmd.run
      end
    end)
  end

  @spec ensure_exists(Coach.Path.t, file_type) :: Cmd.t
  def ensure_exists(path, :dir) do
    Function.from_function(fn ->
      path = Coach.Path.path(path)
      unless File.exists?(path) do
        File.mkdir_p(path)
      end
    end)
  end
end
