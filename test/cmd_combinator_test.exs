defmodule Coach.Cmd.Combinator.Test do
  use ExUnit.Case

  @test_module Coach.Cmd.Combinator

  alias Coach.Cmd

  setup do
    cmd1 = Cmd.new |> Cmd.with_command("echo")
    cmd2 = Cmd.new |> Cmd.with_command("echo") |> Cmd.with_value("Hello world")
    cmd3 = Cmd.new |> Cmd.with_command("echo") |> Cmd.with_value("Hello there!")

    state = %{
      cmd1: cmd1,
      cmd2: cmd2,
      cmd3: cmd3
    }

    {:ok, state}
  end

  describe "then" do
    test "accepts a cmd and a cmd", %{cmd1: cmd1, cmd2: cmd2} do
      %@test_module.And{first: ^cmd1, second: ^cmd2} = @test_module.then(cmd1, cmd2)
    end

    test "accepts a combinator and a cmd", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.then(cmd1, cmd2)

      %@test_module.And{first: ^both, second: ^cmd3} = @test_module.then(both, cmd3)
    end

    test "accepts a cmd and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.then(cmd1, cmd2)

      %@test_module.And{first: ^cmd3, second: ^both} = @test_module.then(cmd3, both)
    end

    test "accepts a combinator and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      a = @test_module.then(cmd1, cmd2)
      b = @test_module.then(cmd2, cmd3)

      %@test_module.And{first: ^a, second: ^b} = @test_module.then(a, b)
    end
  end

  describe "otherwise" do
    test "accepts a cmd and a cmd", %{cmd1: cmd1, cmd2: cmd2} do
      %@test_module.Or{first: ^cmd1, second: ^cmd2} = @test_module.otherwise(cmd1, cmd2)
    end

    test "accepts a combinator and a cmd", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.otherwise(cmd1, cmd2)

      %@test_module.Or{first: ^both, second: ^cmd3} = @test_module.otherwise(both, cmd3)
    end

    test "accepts a cmd and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.otherwise(cmd1, cmd2)

      %@test_module.Or{first: ^cmd3, second: ^both} = @test_module.otherwise(cmd3, both)
    end

    test "accepts a combinator and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      a = @test_module.otherwise(cmd1, cmd2)
      b = @test_module.otherwise(cmd2, cmd3)

      %@test_module.Or{first: ^a, second: ^b} = @test_module.otherwise(a, b)
    end
  end

  describe "ensure" do
    test "accepts a cmd and a cmd", %{cmd1: cmd1, cmd2: cmd2} do
      %@test_module.Ensure{first: ^cmd1, second: ^cmd2} = @test_module.ensure(cmd1, cmd2)
    end

    test "accepts a combinator and a cmd", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.ensure(cmd1, cmd2)

      %@test_module.Ensure{first: ^both, second: ^cmd3} = @test_module.ensure(both, cmd3)
    end

    test "accepts a cmd and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      both = @test_module.ensure(cmd1, cmd2)

      %@test_module.Ensure{first: ^cmd3, second: ^both} = @test_module.ensure(cmd3, both)
    end

    test "accepts a combinator and a combinator", %{cmd1: cmd1, cmd2: cmd2, cmd3: cmd3} do
      a = @test_module.ensure(cmd1, cmd2)
      b = @test_module.ensure(cmd2, cmd3)

      %@test_module.Ensure{first: ^a, second: ^b} = @test_module.ensure(a, b)
    end
  end
end
