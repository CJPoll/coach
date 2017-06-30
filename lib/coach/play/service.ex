defmodule Coach.Play.Service do
  alias Coach.Cmd

  @type action :: :start | :stop | :restart
  @type service :: String.t
  @actions [:start, :stop, :restart]

  defstruct [action: nil, services: [], os: nil]

  @type t :: %__MODULE__{
    services: [service],
    action: action | nil,
    os: Coach.Os.os | nil
  }

  @doc """
  This function is only needed for testing.
  By default, Coach.Play.Service will detect which OS you are running on.
  """
  @spec for_os(t, Coach.Os.os) :: t
  def for_os(%__MODULE__{} = commandable, os) do
    %__MODULE__{commandable | os: os}
  end

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec start(service | [service]) :: Cmd.t
  def start(service) when is_binary(service) do
    start([service])
  end

  def start(services) when is_list(services) do
    bulk_action(services, :start)
  end

  @spec stop(service | [service]) :: Cmd.t
  def stop(service) when is_binary(service) do
    stop([service])
  end

  def stop(services) when is_list(services) do
    bulk_action(services, :stop)
  end

  @spec restart(service | [service]) :: Cmd.t
  def restart(service) when is_binary(service) do
    restart([service])
  end

  def restart(services) when is_list(services) do
    bulk_action(services, :restart)
  end

  @spec with_service(t, service) :: t
  def with_service(%__MODULE__{} = commandable, service) when is_binary(service) do
    %__MODULE__{commandable | services: [service | commandable.services]}
  end

  @spec with_action(t, action) :: t
  def with_action(%__MODULE__{} = commandable, action) when action in @actions do
    %__MODULE__{commandable | action: action}
  end

  @doc false
  @spec bulk_action([service], action) :: t
  defp bulk_action(services, action) do
    commandable = new() |> with_action(action)

    services
    |> :lists.reverse
    |> Enum.reduce(commandable, fn(service, %__MODULE__{} = commandable) ->
      with_service(commandable, service)
    end)
  end

  def tmux_active? do
    "TMUX"
    |> System.get_env
    |> tmux_active?
  end

  def tmux_active?(nil), do: false
  def tmux_active?(bin) when is_binary(bin) do
    bin = bin |> IO.inspect |> String.trim
    bin != ""
  end
end

defimpl Commandable, for: Coach.Play.Service do
  alias Coach.Cmd.{Combinator, Shell}

  @mod Coach.Play.Service

  def to_cmd(%@mod{os: nil} = commandable) do
    os = Coach.Os.current_os()
    to_cmd(%@mod{commandable | os: os})
  end

  def to_cmd(%@mod{action: nil}) do
    raise "#{@mod} requires you to set an action"
  end

  def to_cmd(%@mod{os: :mac} = commandable) do
    IO.inspect("Checking TMUX:")
    if @mod.tmux_active? |> IO.inspect do
      raise "brew services can't run under tmux - this command will fail: #{inspect commandable}"
    end

    action =
      Shell.new()
      |> Shell.with_command("brew")
      |> Shell.with_value("services")
      |> Shell.with_value("#{commandable.action}")

    commandable.services
    |> Enum.map(fn(service) -> Shell.with_value(action, service) end)
    |> Enum.reduce(fn(right, left) -> Combinator.then(left, right) end)
  end
end
