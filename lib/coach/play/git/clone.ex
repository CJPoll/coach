defmodule Coach.Play.Git.Clone do
  defstruct [
    :repo,
    :directory
  ]
  @type t :: %__MODULE__{}

  @type repo :: String.t

  @spec from_repo(t, repo) :: t
  def from_repo(%__MODULE__{} = cloner, repo) do
    %__MODULE__{cloner | repo: repo}
  end

  @spec to_directory(t, Path.t) :: t
  def to_directory(%__MODULE__{} = cloner, directory) do
    %__MODULE__{cloner | directory: directory}
  end

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end
end

defimpl Commandable, for: Coach.Play.Git.Clone do
  alias Coach.Cmd.Shell

  def to_cmd(%Coach.Play.Git.Clone{repo: repo} = commandable) do
    cmd =
      Shell.new()
      |> Shell.with_command("git")
      |> Shell.with_value("clone")
      |> Shell.with_value(repo)

    if commandable.directory do
      Shell.with_value(cmd, commandable.directory)
    else
      cmd
    end
  end
end
