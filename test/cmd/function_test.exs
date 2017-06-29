defmodule Coach.Cmd.Function.Test do
  use ExUnit.Case
  alias Coach.Cmd

  @test_module Coach.Cmd.Function

  describe "from_function/1" do
    test "returns the value returned by the function" do
      actual =
        fn -> :hi end
        |> @test_module.from_function
        |> Cmd.run

      assert actual == :hi
    end
  end

  describe "from_function/2" do
    test "works with a function of arity 0" do
      actual =
        fn -> :hi end
        |> @test_module.from_function([])
        |> Cmd.run

      assert actual == :hi
    end

    test "works with a function of arity > 0" do
      actual =
        fn(a) -> a end
        |> @test_module.from_function([:hi])
        |> Cmd.run

      assert actual == :hi
    end
  end

  describe "from_function/3" do
    test "works with an mfa" do
      defmodule TestModule do
        def identity(a) do
          a
        end
      end

      actual =
        TestModule
        |> @test_module.from_function(:identity, [:hi])
        |> Cmd.run

      assert actual == :hi
    end
  end
end
