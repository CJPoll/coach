defmodule Coach.Play.Service do
  alias Coach.Cmd
  alias Coach.Cmd.Combinator

  @type action :: :start | :stop | :restart
  @type service :: String.t
  @actions [:start, :stop, :restart]

  defstruct [services: [], action: nil]

  @type t :: %__MODULE__{
    services: [service],
    action: action | nil
  }

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

  @spec to_cmd(t) :: Cmd.t
  def to_cmd(%__MODULE__{} = intent) do
    os = Coach.Os.current_os()
    to_cmd(intent, os)
  end

  @spec to_cmd(t, Coach.Os.os) :: Cmd.t
  defp to_cmd(%__MODULE__{} = intent, :mac) do
    action =
      Cmd.new()
      |> Cmd.with_command("brew")
      |> Cmd.with_value("services")
      |> Cmd.with_value("#{intent.action}")

    intent.services
    |> Enum.map(fn(service) -> Cmd.with_value(action, service) end)
    |> Enum.reduce(fn(right, left) -> Combinator.then(left, right) end)
  end

  @spec with_service(t, service) :: t
  def with_service(%__MODULE__{} = intent, service) when is_binary(service) do
    %__MODULE__{intent | services: [service | intent.services]}
  end

  @spec with_action(t, action) :: t
  def with_action(%__MODULE__{} = intent, action) when action in @actions do
    %__MODULE__{intent | action: action}
  end

  @spec bulk_action([service], action) :: Cmd.t
  defp bulk_action(services, action) do
    intent = new() |> with_action(action)

    services
    |> :lists.reverse
    |> Enum.reduce(intent, fn(service, %__MODULE__{} = intent) ->
      with_service(intent, service)
    end)
    |> to_cmd
  end
end
