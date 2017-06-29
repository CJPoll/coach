defmodule Coach.Play.Copy.Test do
  use ExUnit.Case

  alias Coach.Cmd.{Function, Shell}
  alias Coach.Cmd

  @test_module Coach.Play.Copy
  @source_file "/tmp/filea"
  @destination_file "/tmp/fileb"

  describe "as shell" do
    test "uses the cp command" do
      shell =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> Cmd.to_cmd

      assert Shell.command?(shell, "cp")
    end

    test "uses the -r option if make_parent_dirs specified" do
      shell =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> @test_module.make_parent_dirs
        |> Cmd.to_cmd

      assert Shell.flag?(shell, "-r")
    end

    test "does not use the -r option if make_parent_dirs not specified" do
      shell =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> Cmd.to_cmd

      refute Shell.flag?(shell, "-r")
    end

    test "builds a cp command correctly" do
      actual =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> Cmd.to_cmd
        |> Shell.to_string

      assert actual == ~s(cp "#{@source_file}" "#{@destination_file}")
    end
  end

  describe "as function" do
    test "calls File.cp_r if parent_dirs set and as_function specified" do
      func =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> @test_module.as_function
        |> @test_module.make_parent_dirs
        |> Cmd.to_cmd

      assert %Function{module: File, function: :cp_r} = func
    end

    test "calls File.cp if as_function specified" do
      func =
        @test_module.new()
        |> @test_module.from(@source_file)
        |> @test_module.to(@destination_file)
        |> @test_module.as_function
        |> Cmd.to_cmd

      assert %Function{module: File, function: :cp} = func
    end
  end
end
