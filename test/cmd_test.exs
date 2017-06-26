defmodule Coach.Cmd.Test do
  use ExUnit.Case

  @test_module Coach.Cmd

  def status_code({_cmd_result, status_code}) do
    status_code
  end

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

  describe "with_command" do
    test "Sets a command that hasn't been set before" do
      %@test_module{command: "hi!"} =
        @test_module.new()
        |> @test_module.with_command("hi!")
    end

    test "Sets a command that has been set before" do
      %@test_module{command: "there"} =
        @test_module.new()
        |> @test_module.with_command("hi!")
        |> @test_module.with_command("there")
    end
  end

  describe "with_flag" do
    test "prepends a flag to the args" do
      %@test_module{args: [{:flag, "--world"}, {:flag, "--hello"}]} =
        @test_module.new
        |> @test_module.with_flag("--hello")
        |> @test_module.with_flag("--world")
    end

    test "prepends a flag and its associated value to the args" do
      %@test_module{args: [{:flag, "--target", "world"}, {:flag, "--greeting", "hello"}]} =
        @test_module.new
        |> @test_module.with_flag("--greeting", "hello")
        |> @test_module.with_flag("--target", "world")
    end
  end

  describe "with_value" do
    test "prepends an arbitrary value to the list of args" do
      %@test_module{args: [{:value, "/etc"}, {:flag, "--hello"}]} =
        @test_module.new
        |> @test_module.with_flag("--hello")
        |> @test_module.with_value("/etc")
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

  describe "run" do
    @tag current: true
    test "getting stdout" do
      status_code =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_value("hi there cody!")
        |> @test_module.run
        |> status_code

      assert status_code == 0
    end
  end

  describe "testability" do
    test "can query which flags are in the query" do
      cmd =
        @test_module.new
        |> @test_module.with_command("echo")
        |> @test_module.with_flag("--greeting", "hello")
        |> @test_module.with_flag("--stuffs")
        |> @test_module.with_value("blah")

      assert @test_module.command?(cmd, "echo")
      refute @test_module.command?(cmd, "blah")

      assert @test_module.flag?(cmd, "--greeting")
      assert @test_module.flag?(cmd, "--greeting", "hello")
      assert @test_module.flag?(cmd, "--stuffs")

      refute @test_module.flag?(cmd, "--greeting", "fake")
      refute @test_module.flag?(cmd, "greeting")
      refute @test_module.flag?(cmd, "--stuffs", "fake")
      refute @test_module.flag?(cmd, "fake", "fake")

      assert @test_module.flag_value(cmd, "--greeting") == "hello"
      assert @test_module.has_value?(cmd, "blah")
      refute @test_module.has_value?(cmd, "blase")
    end
  end
end
