defmodule Coach.Play.Extract.Test do
  use ExUnit.Case
  @test_module Coach.Play.Extract
  alias Coach.Cmd

  setup do
    source = Path.join(System.user_home, "/test/file")
    destination = Path.join(System.user_home, "/test/fileb")

    state =
      %{ source: source,
         destination: destination }

    {:ok, state}
  end

  describe "new" do
    test "returns an Extractor" do
      %@test_module{} = @test_module.new()
    end
  end

  describe "to_cmd" do
    test "Uses tar" do
      uses_tar =
        @test_module.new()
        |> @test_module.from_file("abc")
        |> @test_module.to_cmd()
        |> Cmd.command?("tar")

      assert uses_tar
    end

    test "includes the source file", %{source: source} do
      has_source =
        @test_module.new()
        |> @test_module.from_file(source)
        |> @test_module.to_cmd
        |> Cmd.has_value?(source)

      assert has_source
    end

    test "includes the destination if given", %{source: source, destination: destination} do
      has_destination =
        @test_module.new()
        |> @test_module.from_file(source)
        |> @test_module.to_file(destination)
        |> @test_module.to_cmd
        |> Cmd.flag?("-C", destination)

      assert has_destination
    end

    test "does not include the destination if not given", %{source: source} do
      has_destination =
        @test_module.new()
        |> @test_module.from_file(source)
        |> @test_module.to_cmd
        |> Cmd.flag?("-C")

      refute has_destination
    end

    test "takes into account strip_components", %{source: source} do
      strip =
        @test_module.new()
        |> @test_module.from_file(source)
        |> @test_module.strip_components(10)
        |> @test_module.to_cmd
        |> Cmd.flag?("--strip-components", "10")

      assert strip
    end
  end
end
