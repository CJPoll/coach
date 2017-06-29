defmodule Coach.Play.Extract do
  defstruct [:destination, :source, strip_components: nil, keep_newer_files: false]
  @type integer_string :: String.t
  @type t :: %__MODULE__{
    destination: Path.t | :stdout | nil,
    source: Path.t | :stdin | nil,
    strip_components: integer_string | nil,
    keep_newer_files: boolean
  }

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec from(t, Path.t | :stdin) :: t
  def from(extractor, source) do
    %__MODULE__{extractor | source: source}
  end

  @spec keep_newer_files(t) :: t
  def keep_newer_files(extractor) do
    %__MODULE__{extractor | keep_newer_files: true}
  end

  @spec strip_components(t, non_neg_integer) :: t
  def strip_components(extractor, count) when (is_integer(count) and count >= 0) or is_binary(count) do
    %__MODULE__{extractor | strip_components: Integer.to_string(count)}
  end

  @spec to(t, Path.t | :stdout) :: t
  def to(extractor, destination) do
    %__MODULE__{extractor | destination: destination}
  end
end

defimpl Commandable, for: Coach.Play.Extract do
  alias Coach.Cmd.Shell

  @spec to_cmd(Coach.Play.Extract.t) :: Shell.t | no_return
  def to_cmd(%Coach.Play.Extract{source: nil}) do
    raise "Can't extract file: Missing source"
  end

  def to_cmd(%Coach.Play.Extract{source: source, destination: destination} = commandable)
  when (is_binary(source) or source == :stdin)
  and (is_binary(destination) or destination == :stdout)do
    Shell.new()
    |> Shell.with_command("tar")
    |> Shell.with_flag("-x")
    |> Shell.with_flag("-v")
    |> Shell.with_flag("-f", source, if: is_binary(source))
    |> Shell.with_flag("-f", "-", unless: is_binary(source))
    |> Shell.with_flag("--strip-components", commandable.strip_components, if: commandable.strip_components)
    |> Shell.with_flag("-C", "-", unless: is_binary(destination))
    |> Shell.with_flag("-C", destination, if: is_binary(destination))
    |> Shell.with_flag("--keep-newer-files", if: commandable.keep_newer_files)
  end
end
