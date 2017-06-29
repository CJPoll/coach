defmodule Coach.Play.Download.Test do
  use ExUnit.Case
  alias Coach.Cmd
  alias Coach.Cmd.{Function, Shell}

  @test_module Coach.Play.Download

  @uri %URI{scheme: "http", host: "github.com", path: "cjpoll/coach"}
  @local_path "/tmp/filea"

  describe "curl" do
    test "returns a function if check_exists" do
      func =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> @test_module.unless_downloaded
        |> Cmd.to_cmd

      assert %Function{} = func
    end

    test "returns a shell if not check_exists" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> Cmd.to_cmd

      assert %Shell{} = shell
    end

    test "returns a curl command by default" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> Cmd.to_cmd

      assert Shell.command?(shell, "curl")
    end

    test "includes the --location flag" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "--location")
    end

    test "pipes to stdout if configured to" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(:stdout)
        |> Cmd.to_cmd

      refute Shell.flag?(shell, "-o")
    end

    test "saves to file if configured to" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "-o", @local_path)
      refute Shell.flag?(shell, "-o", "-")
    end

    test "creates dirs if saving to file" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "--create-dirs")
    end

    test "does not create dirs if not saving to file" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(:stdout)
        |> Cmd.to_cmd

      refute Shell.flag?(shell, "--create-dirs")
    end

    test "raises an exception if a destination is not set" do
      assert_raise(RuntimeError, "Coach.Play.Download requires the destination to be set to either :stdout or a file path", fn ->
        @test_module.new()
        |> @test_module.from(@uri)
        |> Cmd.to_cmd
      end)
    end
  end

  describe "wget" do
    test "raises an exception if a destination is not set" do
      assert_raise(RuntimeError, "Coach.Play.Download requires the destination to be set to either :stdout or a file path", fn ->
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.using_bin(:wget)
        |> Cmd.to_cmd
      end)
    end

    test "uses wget if configured to" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(:stdout)
        |> @test_module.using_bin(:wget)
        |> Cmd.to_cmd

      assert Shell.command?(shell, "wget")
    end

    test "sets the output file if destination is a file path" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(@local_path)
        |> @test_module.using_bin(:wget)
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "-O", @local_path)
    end

    test "sets stdout as the output file if destination is stdout" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(:stdout)
        |> @test_module.using_bin(:wget)
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "-O", "-")
    end

    test "has the source url as a value" do
      shell =
        @test_module.new()
        |> @test_module.from(@uri)
        |> @test_module.to(:stdout)
        |> @test_module.using_bin(:wget)
        |> Cmd.to_cmd

      assert Shell.has_value?(shell, URI.to_string(@uri))
    end
  end
end
