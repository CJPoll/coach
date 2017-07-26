defmodule Coach.Play.ASDF do
  alias Coach.Cmd.Shell

  def add_plugin(plugin, repo) do
    Shell.new()
    |> Shell.with_command("asdf")
    |> Shell.with_value("plugin-add")
    |> Shell.with_value(plugin)
    |> Shell.with_value(repo)
  end

  def install_version(plugin, version) do
    Shell.new()
    |> Shell.with_command("asdf")
    |> Shell.with_value("install")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end

  def set_global(plugin, version) do
    Shell.new()
    |> Shell.with_command("asdf")
    |> Shell.with_value("global")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end

  def set_local(plugin, version) do
    Shell.new()
    |> Shell.with_command("asdf")
    |> Shell.with_value("local")
    |> Shell.with_value(plugin)
    |> Shell.with_value(version)
  end
end
