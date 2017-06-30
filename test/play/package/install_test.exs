defmodule Coach.Play.Package.Install.Test do
  use ExUnit.Case
  alias Coach.Cmd
  alias Coach.Cmd.Shell

  @test_module Coach.Play.Package.Install

  describe "mac" do
    @os :mac

    test "uses brew" do
      shell =
        @test_module.new()
        |> @test_module.for_os(@os)
        |> @test_module.install(@os, "rabbitmq")
        |> @test_module.install(@os, "kafka")
        |> Cmd.to_cmd

      assert Shell.command?(shell, "brew")
    end

    test "does an install" do
      shell =
        @test_module.new()
        |> @test_module.for_os(@os)
        |> @test_module.install(@os, "rabbitmq")
        |> @test_module.install(@os, "kafka")
        |> Cmd.to_cmd

      assert Shell.has_value?(shell, "install")
    end

    test "Installs all of the specified packages" do
      shell =
        @test_module.new()
        |> @test_module.for_os(@os)
        |> @test_module.install(@os, "rabbitmq")
        |> @test_module.install(@os, "kafka")
        |> Cmd.to_cmd

      assert Shell.has_value?(shell, "rabbitmq")
      assert Shell.has_value?(shell, "kafka")
    end
  end
end
