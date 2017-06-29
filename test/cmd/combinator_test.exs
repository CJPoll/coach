defmodule Coach.Cmd.Combinator.Test do
  use ExUnit.Case

  @test_module Coach.Cmd.Combinator

  alias Coach.Cmd
  alias Coach.Cmd.{Function, Shell}

  def mailbox_contains?(msg) do
    receive do
      ^msg -> true
    after
      0 -> false
    end
  end

  def flush_mailbox do
    receive do
      _ -> flush_mailbox()
    after
      0 -> :ok
    end
  end

  setup do
    shell1 = Shell.new |> Shell.with_command("echo")
    shell2 = Shell.new |> Shell.with_command("echo") |> Shell.with_value("Hello world")
    shell3 = Shell.new |> Shell.with_command("echo") |> Shell.with_value("Hello there!")

    func = fn
      (:succeed) ->
        send(self(), :succeed)
        :ok
      (:fail) ->
        send(self(), :fail)
        :error
    end

    succeed = Function.from_function(func, [:succeed])
    fail = Function.from_function(func, [:fail])

    state = %{
      shell1: shell1,
      shell2: shell2,
      shell3: shell3,
      succeed: succeed,
      fail: fail
    }

    on_exit(&__MODULE__.flush_mailbox/0)

    {:ok, state}
  end

  describe "then" do
    test "accepts a shell and a shell", %{shell1: shell1, shell2: shell2} do
      %@test_module.And{first: ^shell1, second: ^shell2} = @test_module.then(shell1, shell2)
    end

    test "accepts a combinator and a shell", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.then(shell1, shell2)

      %@test_module.And{first: ^both, second: ^shell3} = @test_module.then(both, shell3)
    end

    test "accepts a shell and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.then(shell1, shell2)

      %@test_module.And{first: ^shell3, second: ^both} = @test_module.then(shell3, both)
    end

    test "accepts a combinator and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      a = @test_module.then(shell1, shell2)
      b = @test_module.then(shell2, shell3)

      %@test_module.And{first: ^a, second: ^b} = @test_module.then(a, b)
    end
  end

  describe "otherwise" do
    test "accepts a shell and a shell", %{shell1: shell1, shell2: shell2} do
      %@test_module.Or{first: ^shell1, second: ^shell2} = @test_module.otherwise(shell1, shell2)
    end

    test "accepts a combinator and a shell", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.otherwise(shell1, shell2)

      %@test_module.Or{first: ^both, second: ^shell3} = @test_module.otherwise(both, shell3)
    end

    test "accepts a shell and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.otherwise(shell1, shell2)

      %@test_module.Or{first: ^shell3, second: ^both} = @test_module.otherwise(shell3, both)
    end

    test "accepts a combinator and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      a = @test_module.otherwise(shell1, shell2)
      b = @test_module.otherwise(shell2, shell3)

      %@test_module.Or{first: ^a, second: ^b} = @test_module.otherwise(a, b)
    end
  end

  describe "ensure" do
    test "accepts a shell and a shell", %{shell1: shell1, shell2: shell2} do
      %@test_module.Ensure{first: ^shell1, second: ^shell2} = @test_module.ensure(shell1, shell2)
    end

    test "accepts a combinator and a shell", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.ensure(shell1, shell2)

      %@test_module.Ensure{first: ^both, second: ^shell3} = @test_module.ensure(both, shell3)
    end

    test "accepts a shell and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      both = @test_module.ensure(shell1, shell2)

      %@test_module.Ensure{first: ^shell3, second: ^both} = @test_module.ensure(shell3, both)
    end

    test "accepts a combinator and a combinator", %{shell1: shell1, shell2: shell2, shell3: shell3} do
      a = @test_module.ensure(shell1, shell2)
      b = @test_module.ensure(shell2, shell3)

      %@test_module.Ensure{first: ^a, second: ^b} = @test_module.ensure(a, b)
    end
  end

  describe "otherwise execution" do
    test "executes only the left if the left succeeds", %{succeed: succeed, fail: fail} do
      succeed
      |> @test_module.otherwise(fail)
      |> Cmd.run

      assert mailbox_contains?(:succeed)
      refute mailbox_contains?(:fail)
    end

    test "executes the left and right if the left fails", %{succeed: succeed, fail: fail} do
      fail
      |> @test_module.otherwise(succeed)
      |> Cmd.run

      assert mailbox_contains?(:succeed)
      assert mailbox_contains?(:fail)
    end
  end

  describe "then execution" do
    test "executes only the left if the left fails", %{succeed: succeed, fail: fail} do
      fail
      |> @test_module.then(succeed)
      |> Cmd.run

      assert mailbox_contains?(:fail)
      refute mailbox_contains?(:succeed)
    end

    test "executes the left and right if the left succeeds", %{succeed: succeed, fail: fail} do
      succeed
      |> @test_module.then(fail)
      |> Cmd.run

      assert mailbox_contains?(:succeed)
      assert mailbox_contains?(:fail)
    end
  end

  describe "ensure execution" do
    test "executes the right if the left fails", %{succeed: succeed, fail: fail} do
      fail
      |> @test_module.ensure(succeed)
      |> Cmd.run

      assert mailbox_contains?(:fail)
      assert mailbox_contains?(:succeed)
    end

    test "executes the right if the left succeeds", %{succeed: succeed, fail: fail} do
      succeed
      |> @test_module.then(fail)
      |> Cmd.run

      assert mailbox_contains?(:succeed)
      assert mailbox_contains?(:fail)
    end
  end
end

