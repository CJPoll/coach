defmodule Coach.Play.Git.Clone do
  defmodule RepoNotSpecified do
    defexception [message: "Repo not specified for git clone"]
  end

  defstruct [
    :branch,
    :directory,
    :repo
  ]
  @type t :: %__MODULE__{}

  @type repo :: String.t
  @type branch :: String.t

  @spec branch(t, branch) :: t
  def branch(%__MODULE__{} = commandable, branch) do
    %__MODULE__{commandable | branch: branch}
  end

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

  def to_cmd(%Coach.Play.Git.Clone{repo: repo, branch: branch} = commandable) when is_binary(repo) do
    Shell.new()
    |> Shell.with_command("git")
    |> Shell.with_value("clone")
    |> Shell.with_flag("--branch", branch, if: branch)
    |> Shell.with_value(repo)
    |> Shell.with_value(commandable.directory, [if: commandable.directory])
  end

  def to_cmd(%Coach.Play.Git.Clone{repo: nil}) do
    raise Coach.Play.Git.Clone.RepoNotSpecified
  end
end
