defmodule Coach.Play.Chsh do
  @type user :: String.t
  @type shell :: String.t

  defstruct [:shell, :user]
  @type t :: %__MODULE__{
    user: user | nil,
    shell: shell | nil
  }

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec shell(t, shell) :: t
  def shell(%__MODULE__{} = commandable, shell) do
    %__MODULE__{commandable | shell: shell}
  end

  @spec user(t, user) :: t
  def user(%__MODULE__{} = commandable, user) do
    %__MODULE__{commandable | user: user}
  end
end

defimpl Commandable, for: Coach.Play.Chsh do
  alias Coach.Cmd.Shell

  @mod Coach.Play.Chsh

  def to_cmd(%@mod{} = commandable) do
    Shell.new()
    |> Shell.with_command("chsh")
    |> Shell.with_flag("-s", commandable.shell)
    |> Shell.with_value(commandable.user)
  end
end
