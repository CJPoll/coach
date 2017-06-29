defmodule Coach.Play.Git.Clone.Test do
  use ExUnit.Case
  alias Coach.Cmd
  alias Coach.Cmd.Shell
  alias Coach.Play.Git.Clone.RepoNotSpecified

  @test_module Coach.Play.Git.Clone
  @repo "git@github.com:cjpoll/coach"
  @local_path Path.join([System.user_home, "dev", "coach"])

  test "raises an exception if repo is not set" do
    assert_raise(RepoNotSpecified, "Repo not specified for git clone", fn ->
      @test_module.new()
      |> @test_module.to_directory("/tmp/place")
      |> Cmd.to_cmd
    end)
  end

  test "Runs git clone" do
    cmd =
      @test_module.new()
      |> @test_module.from_repo("git@github.com:cjpoll/coach")
      |> Cmd.to_cmd

    assert Shell.command?(cmd, "git")
    assert Shell.has_value?(cmd, "clone")
  end

  test "includes the repository" do
    cmd =
      @test_module.new()
      |> @test_module.from_repo(@repo)
      |> Cmd.to_cmd

    assert Shell.has_value?(cmd, @repo)
  end

  test "does not include the local path if not specified" do
    cmd =
      @test_module.new()
      |> @test_module.from_repo(@repo)
      |> Cmd.to_cmd

    refute Shell.has_value?(cmd, @local_path)
  end

  test "includes the local path if specified" do
    cmd =
      @test_module.new()
      |> @test_module.from_repo(@repo)
      |> @test_module.to_directory(@local_path)
      |> Cmd.to_cmd

    assert Shell.has_value?(cmd, @local_path)
  end
end
