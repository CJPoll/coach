defmodule Coach.Play.Service.Test do
  use ExUnit.Case
  alias Coach.Cmd
  alias Coach.Cmd.Shell
  alias Coach.Cmd.Combinator.And
  @test_module Coach.Play.Service

  describe "mac start" do
    test "uses brew" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:start)
        |> Cmd.to_cmd

      Shell.command?(shell, "brew")
    end

    test "registers the start action" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:start)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "start")
    end

    test "starts the given service" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:start)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "kafka")
    end

    test "works when given multiple services" do
      %And{first: left, second: right} =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_service("rabbitmq")
        |> @test_module.with_action(:start)
        |> Cmd.to_cmd


      assert Shell.has_value?(left, "rabbitmq")
      assert Shell.has_value?(right, "kafka")
    end
  end

  describe "mac stop" do
    test "uses brew" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:stop)
        |> Cmd.to_cmd

      Shell.command?(shell, "brew")
    end

    test "registers the stop action" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:stop)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "stop")
    end

    test "stops the given service" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:stop)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "kafka")
    end

    test "works when given multiple services" do
      %And{first: left, second: right} =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_service("rabbitmq")
        |> @test_module.with_action(:stop)
        |> Cmd.to_cmd


      assert Shell.has_value?(left, "rabbitmq")
      assert Shell.has_value?(right, "kafka")
    end
  end

  describe "mac restart" do
    test "uses brew" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:restart)
        |> Cmd.to_cmd

      Shell.command?(shell, "brew")
    end

    test "registers the restart action" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:restart)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "restart")
    end

    test "restarts the given service" do
      shell =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_action(:restart)
        |> Cmd.to_cmd

      Shell.has_value?(shell, "kafka")
    end

    test "works when given multiple services" do
      %And{first: left, second: right} =
        @test_module.new()
        |> @test_module.with_service("kafka")
        |> @test_module.with_service("rabbitmq")
        |> @test_module.with_action(:restart)
        |> Cmd.to_cmd


      assert Shell.has_value?(left, "rabbitmq")
      assert Shell.has_value?(right, "kafka")
    end
  end
end
