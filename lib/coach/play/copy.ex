defmodule Coach.Play.Copy do
  defstruct [from: nil, parent_dirs: false, shell: true, to: nil]
  @type t :: %__MODULE__{}

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec from(t, Path.t) :: t
  def from(copier, path) do
    %__MODULE__{copier | from: path}
  end

  @spec to(t, Path.t) :: t
  def to(copier, path) do
    %__MODULE__{copier | to: path}
  end

  @spec as_function(t) :: t
  def as_function(%__MODULE__{} = copier) do
    %__MODULE__{copier | shell: false}
  end

  def make_parent_dirs(copier) do
    %__MODULE__{copier | parent_dirs: true}
  end
end

defimpl Commandable, for: Coach.Play.Copy do
  alias Coach.Cmd.{Function, Shell}

  @spec to_cmd(Coach.Play.Copy.t) :: Shell.t
  def to_cmd(%Coach.Play.Copy{from: from, to: to, shell: true} = commandable)
  when is_binary(from) and is_binary(to) do
    Shell.new()
    |> Shell.with_command("cp")
    |> Shell.with_flag("-r", if: commandable.parent_dirs)
    |> Shell.with_value(from)
    |> Shell.with_value(to)
  end

  def to_cmd(%Coach.Play.Copy{from: from, to: to, shell: false, parent_dirs: true}) do
    Function.from_function(File, :cp_r, [from, to])
  end

  def to_cmd(%Coach.Play.Copy{from: from, to: to, shell: false}) do
    Function.from_function(File, :cp, [from, to])
  end
end
