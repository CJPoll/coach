defmodule Coach.Play.Git.Clone do
  alias Coach.Cmd

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

  @spec to_cmd(t) :: Cmd.t
  def to_cmd(%__MODULE__{repo: repo} = cloner) do
    cmd =
      Cmd.new()
      |> Cmd.with_command("git")
      |> Cmd.with_value("clone")
      |> Cmd.with_value(repo)

    if cloner.directory do
      Cmd.with_value(cmd, cloner.directory)
    else
      cmd
    end
  end
end
