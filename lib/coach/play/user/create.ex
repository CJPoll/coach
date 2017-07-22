defmodule Coach.Play.User.Create do
  @type username :: String.t

  defstruct [:home, :user]
  @type t :: %__MODULE__{
    user: username,
    home: Path.t
  }

  @spec new() :: t
  def new do
    %__MODULE__{}
  end

  @spec user(t, username) :: t
  def user(%__MODULE__{} = cmd, username) do
    %__MODULE__{cmd | user: username}
  end

  def with_home(%__MODULE__{} = cmd, home_dir) do
    %__MODULE__{cmd | home: home_dir}
  end
end

defimpl Commandable, for: Coach.Play.User.Create do
  alias Coach.Cmd.Shell

  @mod Coach.Play.User.Create

  def to_cmd(%@mod{} = commandable) do
    Shell.new()
    |> Shell.with_command("useradd")
    |> Shell.with_flag("-d", commandable.home, if: commandable.home)
    |> Shell.with_flag("-m", if: commandable.home)
    |> Shell.with_value(commandable.user)
  end
end

defimpl Inspect, for: Coach.Play.User.Create do
  @mod Coach.Play.User.Create

  def inspect(%@mod{} = cmd, _opts) do
    cmd
    |> Coach.Cmd.to_cmd
    |> inspect
  end
end
