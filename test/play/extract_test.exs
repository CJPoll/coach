defmodule Coach.Play.Extract.Test do
  use ExUnit.Case

  alias Coach.Cmd
  alias Coach.Cmd.Shell

  @test_module Coach.Play.Extract
  @source Path.join(System.user_home, "/test/file")
  @destination Path.join(System.user_home, "/test/fileb")

  test "uses tar" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    assert Shell.command?(shell, "tar")
  end

  test "can accept stdin as a source" do
    shell =
      @test_module.new()
      |> @test_module.from(:stdin)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "-f", "-")
    refute Shell.flag?(shell, "-f", @source)
  end

  test "can accept a path as a source" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "-f", @source)
    refute Shell.flag?(shell, "-f", "-")
  end

  test "will strip components if configured to" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> @test_module.strip_components(1)
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "--strip-components")
  end

  test "will not strip components if configured to" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    refute Shell.flag?(shell, "--strip-components")
  end

  test "sets the destination to stdout if configured to" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(:stdout)
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "-C", "-")
    refute Shell.flag?(shell, "-C", @source)
  end

  test "sets the destination to a file path if configured to" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "-C", @destination)
    refute Shell.flag?(shell, "-C", "-")
  end

  test "doesn't keep newer files by default" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> Cmd.to_cmd

    refute Shell.flag?(shell, "--keep-newer-files")
  end

  test "keeps newer files if configured to" do
    shell =
      @test_module.new()
      |> @test_module.from(@source)
      |> @test_module.to(@destination)
      |> @test_module.keep_newer_files
      |> Cmd.to_cmd

    assert Shell.flag?(shell, "--keep-newer-files")
  end
end
