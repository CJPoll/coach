defmodule Coach.Play.Download do
  alias Coach.Cmd.Shell
  @type maybe(t) :: t | nil

  defstruct [binary: :curl, check_exists: false, uri: nil, to: nil]
  @type bin :: :curl | :wget
  @type t :: %__MODULE__{
    binary: bin,
    uri: maybe(URI.t),
    to: maybe(Path.t | :stdout),
    check_exists: boolean
  }

  @type conditional :: [] | [unless: term] | [if: term]

  @spec new() :: t
  def new do
    %__MODULE__{}
  end

  @spec from(t, URI.t) :: t
  def from(%__MODULE__{} = commandable, %URI{} = uri) do
    %__MODULE__{commandable | uri: uri}
  end

  def from(_, url) when is_binary(url) do
    raise "Coach.Play.Download requires a %URI{}, not the URL as a string."
  end

  @spec to(t, Path.t | :stdout) :: t
  def to(%__MODULE__{} = commandable, to) when is_binary(to) or to == :stdout do
    %__MODULE__{commandable | to: to}
  end

  @spec to_stdout(t) :: t
  def to_stdout(%__MODULE__{} = commandable) do
    %__MODULE__{commandable | to: :stdout}
  end

  @spec unless_downloaded(t) :: t
  def unless_downloaded(%__MODULE__{to: to} = commandable) when to != :stdout do
    %__MODULE__{commandable | check_exists: true}
  end

  @spec using_bin(t, bin) :: t
  def using_bin(%__MODULE__{} = commandable, binary) when binary in [:curl, :wget] do
    %__MODULE__{commandable | binary: binary}
  end

end

defimpl Commandable, for: Coach.Play.Download do
  alias Coach.Cmd.{Function, Shell}

  @spec to_cmd(Coach.Play.Download.t) :: Function.t | Shell.t
  def to_cmd(%Coach.Play.Download{check_exists: true, binary: :curl} = commandable) do
    Function.from_function(fn ->
      if File.exists?(commandable.to) do
        Shell.new()
        |> Shell.with_command("echo")
        |> Shell.with_value("Not downloading #{URI.to_string(commandable.uri)}. #{commandable.to} already exists")
      else
        shell(%Coach.Play.Download{commandable | check_exists: false}) |> Coach.Cmd.run
      end
    end)
  end

  def to_cmd(%Coach.Play.Download{} = commandable) do
    shell(commandable)
  end

  @spec shell(Coach.Play.Download.t) :: Shell.t
  def shell(%Coach.Play.Download{binary: :curl, to: to} = commandable) when to == :stdout or is_binary(to) do
    url = URI.to_string(commandable.uri)

    Shell.new
    |> Shell.with_command("curl")
    |> Shell.with_flag("--location")
    |> Shell.with_flag("-o", commandable.to, unless: commandable.to == :stdout, if: commandable.to)
    |> Shell.with_flag("--create-dirs", unless: commandable.to == :stdout)
    |> Shell.with_value(url)
  end

  def shell(%Coach.Play.Download{binary: :wget, to: to} = commandable) when to == :stdout or is_binary(to) do
    url = URI.to_string(commandable.uri)

    Shell.new
    |> Shell.with_command("wget")
    |> Shell.with_flag("-O", commandable.to, if: is_binary(commandable.to))
    |> Shell.with_flag("-O", "-", if: commandable.to == :stdout)
    |> Shell.with_value(url)
  end

  def shell(%Coach.Play.Download{}) do
    raise "Coach.Play.Download requires the destination to be set to either :stdout or a file path"
  end
end
