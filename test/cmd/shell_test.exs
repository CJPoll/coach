defmodule Coach.Cmd.Shell.Test do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Coach.Cmd

  @test_module Coach.Cmd.Shell

  describe "new" do
    test "returns a cmd" do
      %@test_module{} = @test_module.new()
    end

    test "does not have a command set by default" do
      %@test_module{command: nil} = @test_module.new()
    end

    test "does not have any arguments set by default" do
      %@test_module{args: []} = @test_module.new()
    end

    test "does not have any options set by default" do
      %@test_module{opts: %{}} = @test_module.new()
    end
  end

  describe "with_command & command && command?" do
    test "Sets a command that hasn't been set before" do
      command = "echo"
      shell = @test_module.with_command(@test_module.new(), command)

      assert @test_module.command(shell) == command
      assert @test_module.command?(shell, command)
    end

    test "Sets a command that has been set before" do
      new_command = "there"
      command =
        @test_module.new()
        |> @test_module.with_command("hi!")
        |> @test_module.with_command(new_command)
        |> @test_module.command

      assert command == new_command
    end
  end

  describe "with_flag && flag? && flag_value" do
    test "prepends a flag to the args" do
      shell =
        @test_module.new
        |> @test_module.with_flag("--hello")
        |> @test_module.with_flag("--world")

      assert @test_module.flag?(shell, "--hello")
      assert @test_module.flag?(shell, "--world")
      refute @test_module.flag?(shell, "--fake")
    end

    test "prepends a flag and its associated value to the args" do
      shell =
        @test_module.new
        |> @test_module.with_flag("--greeting", "hello")
        |> @test_module.with_flag("--target", "world")

      assert @test_module.flag?(shell, "--greeting")
      assert @test_module.flag?(shell, "--greeting", "hello")
      assert @test_module.flag_value(shell, "--greeting") == "hello"
      refute @test_module.flag?(shell, "--greeting", "meh")
      assert @test_module.flag?(shell, "--target", "world")
      assert @test_module.flag_value(shell, "--target") == "world"
      refute @test_module.flag?(shell, "--fake")
      refute @test_module.flag?(shell, "--fake", "meh")
      assert @test_module.flag_value(shell, "--fake") == nil
    end
  end

  describe "with_value && has_value?" do
    test "prepends an arbitrary value to the list of args" do
      shell =
        @test_module.new
        |> @test_module.with_flag("--hello")
        |> @test_module.with_value("/etc")

      assert @test_module.has_value?(shell, "/etc")
      refute @test_module.has_value?(shell, "/etcc")
    end
  end

  describe "to_string" do
    test "shows the command with no spaces if no args" do
      "echo" =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.to_string
    end

    test "shows the command with arguments quoted correctly" do
      ~S(echo "--greeting" "hello world" "you're awesome") =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_flag("--greeting", "hello world")
        |> @test_module.with_value("you're awesome")
        |> @test_module.to_string
    end
  end

  describe "arg_list" do
    test "shows the arguments quoted correctly" do
      actual =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_flag("--greeting", "hello world")
        |> @test_module.with_value("you're awesome")
        |> @test_module.arg_list

      assert ["\"--greeting\"", "\"hello world\"", "\"you're awesome\""] = actual
    end
  end

  describe "arg_string" do
    test "shows the arguments quoted correctly" do
      actual =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_flag("--greeting", "hello world")
        |> @test_module.with_value("you're awesome")
        |> @test_module.arg_string

      assert ~S("--greeting" "hello world" "you're awesome") = actual
    end
  end

  describe "run && status_code" do
    test "prints a message describing the command being run" do
      shell =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_value("Hey there Elixir!")
        |> @test_module.with_value("You're awesome!")

      io = capture_io(fn -> Cmd.run(shell) end)

      assert io == "Running: #{@test_module.to_string(shell)}\n"
    end

    test "returns the command's stdout" do
      capture_io(fn ->
        ret =
          @test_module.new
          |> @test_module.with_command("echo")
          |> @test_module.with_value("Hey there Elixir!")
          |> @test_module.with_value("You're awesome!")
          |> Cmd.run

        assert {"Hey there Elixir! You're awesome!\n", _} = ret
      end)
    end

    test "returns status code 0 on success" do
      capture_io(fn ->
        ret =
          @test_module.new
          |> @test_module.with_command("echo")
          |> @test_module.with_value("Hey there Elixir!")
          |> @test_module.with_value("You're awesome!")
          |> Cmd.run

        assert {_, 0} = ret
      end)
    end

    test "returns a non-zero status code on failure" do
      capture_io(fn ->
        exitish = Path.join(System.cwd(), "test/exitish")
        ret =
          @test_module.new
          |> @test_module.with_command(exitish)
          |> @test_module.with_opt(:stderr_to_stdout, true)
          |> Cmd.run

        assert {_, 1} = ret
      end)
    end
  end
end
