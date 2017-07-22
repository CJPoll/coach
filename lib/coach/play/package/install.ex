defmodule Coach.Play.Package.Install do
  defstruct [current_os: nil, packages: %{}]
  @type maybe(t) :: t | nil
  @type package :: String.t
  @type t :: %__MODULE__{
    current_os: maybe(Coach.Os.os),
    packages: %{
      optional(Coach.Os.os) => [package]
    }
  }

  @spec for_os(t, Coach.Os.os) :: t
  def for_os(%__MODULE__{} = commandable, os) when is_atom(os) do
    %__MODULE__{commandable | current_os: Coach.Os.current_os()}
  end

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec install(t, Coach.Os.os, package) :: Cmd.t
  def install(installer, os, package) do
    Map.update(installer, os, [package], &([package | &1]))
  end
end

defimpl Commandable, for: Coach.Play.Package.Install do
  alias Coach.Cmd.Shell

  @mod Coach.Play.Package.Install

  @spec to_cmd(@for.t) :: Shell.t
  def to_cmd(%@mod{current_os: nil} = commandable) do
    commandable
    |> @mod.for_os(Coach.Os.current_os())
    |> to_cmd
  end

  def to_cmd(%@mod{current_os: :mac} = commandable) do
    packages = Map.get(commandable, :mac, [])

    if packages == [] do
      Coach.Cmd.Function.from_function(fn -> nil end)
    else
      cmd =
        Shell.new
        |> Shell.with_command("brew")
        |> Shell.with_value("install")

      packages
      |> :lists.reverse
      |> Enum.reduce(cmd, fn(package, cmd) ->
        Shell.with_value(cmd, package)
      end)
    end
  end

  def to_cmd(%@mod{current_os: :debian} = commandable) do
    packages = Map.get(commandable, :debian, [])

    if packages == [] do
      Coach.Cmd.Function.from_function(fn -> nil end)
    else
      cmd =
        Shell.new
        |> Shell.with_command("apt-get")
        |> Shell.with_value("install")
        |> Shell.with_flag("-y")

      packages
      |> :lists.reverse
      |> Enum.reduce(cmd, fn(package, cmd) ->
        Shell.with_value(cmd, package)
      end)
    end
  end
end
