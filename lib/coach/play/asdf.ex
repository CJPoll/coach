defmodule Coach.Play.ASDF do
  alias Coach.Cmd.Shell

  def add_plugin(plugin, repo, bin \\ "asdf") do
    Shell.new()
    |> Shell.with_command(Coach.Path.path(bin))
    |> Shell.with_value("plugin-add")
    |> Shell.with_value(plugin)
    |> Shell.with_value(repo)
  end

  def install_version(plugin, version, bin \\ "asdf") do
    Shell.new()
    |> Shell.with_command(Coach.Path.path(bin))
    |> Shell.with_value("install")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end

  def set_global(plugin, version, bin \\ "asdf") do
    Shell.new()
    |> Shell.with_command(Coach.Path.path(bin))
    |> Shell.with_value("global")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end

  def set_local(plugin, version, bin \\ "asdf") do
    Shell.new()
    |> Shell.with_command(Coach.Path.path(bin))
    |> Shell.with_value("local")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end
end
