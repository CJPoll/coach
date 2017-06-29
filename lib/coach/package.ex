defmodule Coach.PackageInstaller do
  defstruct [packages: %{}]
  @type t :: %__MODULE__{}
  @type package :: String.t

  alias Coach.Cmd.Shell

  def new() do
    %__MODULE__{}
  end

  @spec install(t, Coach.Os.os, package) :: Cmd.t
  def install(installer, :mac, package) do
    Map.update(installer, :mac, [package], &([package | &1]))
  end

  @spec to_cmd(t, Coach.Os.os) :: Cmd.t
  def to_cmd(installer, current_os \\ Coach.Os.current_os())

  def to_cmd(%__MODULE__{} = installer, :mac) do
    cmd =
      Shell.new
      |> Shell.with_command("brew")
      |> Shell.with_value("install")

    packages = Map.get(installer, :mac, [])

    packages
    |> :lists.reverse
    |> Enum.reduce(cmd, fn(package, cmd) ->
      Shell.with_value(cmd, package)
    end)
  end
end
