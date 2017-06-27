defmodule Coach.Play.Extract do
  defstruct [:destination, :source, strip_components: nil, keep_newer_files: nil]
  @type t :: %__MODULE__{}

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec from_file(t, Path.t) :: t
  def from_file(extractor, source) do
    %__MODULE__{extractor | source: source}
  end

  @spec keep_newer_files(t) :: t
  def keep_newer_files(extractor) do
    %__MODULE__{extractor | keep_newer_files: true}
  end

  @spec strip_components(t, non_neg_integer) :: t
  def strip_components(extractor, count) when (is_integer(count) and count >= 0) or is_binary(count) do
    %__MODULE__{extractor | strip_components: count}
  end

  @spec to_file(t, Path.t) :: t
  def to_file(extractor, destination) do
    %__MODULE__{extractor | destination: destination}
  end
end

defimpl Commandable, for: Coach.Play.Extract do
  alias Coach.Cmd.Shell

  def to_cmd(%Coach.Play.Extract{source: nil}) do
    raise "Can't extract file: Missing source"
  end

  def to_cmd(%Coach.Play.Extract{source: source} = extractor) do
    cmd =
      Shell.new()
      |> Shell.with_command("tar")
      |> Shell.with_flag("-x")
      |> Shell.with_flag("-v")
      |> Shell.with_flag("-f")
      |> Shell.with_value(source)

    cmd =
      case extractor.strip_components do
        nil -> cmd
        count when is_integer(count) ->
          Shell.with_flag(cmd, "--strip-components", Integer.to_string(count))
        count when is_binary(count) ->
          Shell.with_flag(cmd, "--strip-components", count)
      end

    cmd =
      case extractor.destination do
        nil -> cmd
        destination when is_binary(destination) ->
          Shell.with_flag(cmd, "-C", destination)
      end

    case extractor.keep_newer_files do
      nil -> cmd
      true -> Shell.with_flag(cmd, "--keep-newer-files")
    end
  end
end
