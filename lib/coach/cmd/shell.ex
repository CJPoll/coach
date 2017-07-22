defmodule Coach.Cmd.Shell do
  @type arg0 :: String.t
  @type argument :: flag | value
  @type command :: String.t
  @type condition :: {:if, conditional} | {:unless, conditional}
  @type conditional :: (() -> term) | {((...) -> term), [term]} | {module, atom, [term]} | term
  @type directory :: String.t
  @type env_var_name :: String.t
  @type env_var_value :: String.t
  @type flag :: String.t # "-flag", "-f"
  @type status_code :: non_neg_integer
  @type value :: String.t
  @type return :: {term, status_code}
  @type username :: String.t

  @typep arguments :: [argument] | []
  @type env :: [{env_var_name, env_var_value}]
  @type maybe(t) :: t | nil

  @typep opts :: %{
    optional(:into) => Collectable.t,
    optional(:cd) => directory,
    optional(:env) => [env],
    optional(:arg0) => arg0,
    optional(:stderr_to_stdout) => boolean
  }

  defstruct [args: [], command: nil, opts: %{}, user: nil]

  @type t :: %__MODULE__{
    args: arguments,
    command: maybe(command),
    opts: opts,
    user: nil | username
  }

  @opts [:into, :cd, :env, :arg0, :stderr_to_stdout, :parallelism]

  @spec arg_list(t) :: [String.t]
  def arg_list(%__MODULE__{} = cmd) do
    cmd
    |> build_args
    |> Enum.map(fn(arg)-> "\"#{arg}\"" end)
  end

  @spec arg_string(t) :: String.t
  def arg_string(%__MODULE__{} = cmd) do
    cmd
    |> arg_list
    |> Enum.join(" ")
  end

  @spec as_user(t, username) :: t
  def as_user(%__MODULE__{} = cmd, user) do
    %__MODULE__{cmd | user: user}
  end

  @spec command(t) :: String.t
  def command(%__MODULE__{} = cmd) do
    cmd.command
  end

  @spec command?(t, command) :: boolean
  def command?(%__MODULE__{command: c}, command) do
    c == command
  end

  @spec flag_value(t, flag) :: maybe(value)
  def flag_value(%__MODULE__{args: args}, flag) do
    with {:flag, _flag, value} <- Enum.find(args, fn {:flag, ^flag, _} -> true; _ -> false end) do
      value
    end
  end

  @spec flag?(t, flag) :: boolean
  def flag?(%__MODULE__{args: args}, flag) do
    Enum.any?(args, fn
      ({:flag, ^flag}) -> true
      ({:flag, ^flag, _value}) -> true
      (_) -> false
    end)
  end

  @spec flag?(t, flag, value) :: boolean
  def flag?(%__MODULE__{args: args}, flag, value) do
    Enum.any?(args, fn
      ({:flag, ^flag}) -> false
      ({:flag, ^flag, ^value}) -> true
      (_) -> false
    end)
  end

  @spec has_value?(t, value) :: boolean
  def has_value?(%__MODULE__{args: args}, value) do
    Enum.any?(args, fn
      ({:value, ^value}) -> true
      (_) -> false
    end)
  end

  @spec new() :: t
  def new do
    %__MODULE__{}
  end

  @spec run(t) :: return
  def run(%__MODULE__{command: nil}) do
    raise "Cmd command has not ben set!"
  end

  def run(%__MODULE__{} = cmd) do
    IO.puts("Running: #{__MODULE__.to_string(cmd)}")

    do_run(cmd)
  end

  defp do_run(%__MODULE__{} = cmd) do
    str = __MODULE__.to_string(cmd)
    %Porcelain.Result{out: out, status: status} = Porcelain.shell(str)
    {out, status}
  end

  @spec status_code({Collectable.t, status_code}) :: status_code
  def status_code({_, status_code}), do: status_code

  @spec to_string(t) :: String.t
  def to_string(%__MODULE__{command: command} = cmd) do
    c = String.strip("#{command} #{arg_string(cmd)}")

    if cmd.user do
      "su - #{cmd.user} -c '#{c}'"
    else 
      c
    end
  end

  @spec with_command(t, command) :: t
  def with_command(%__MODULE__{args: args, opts: opts}, command) do
    %__MODULE__{command: command, args: args, opts: opts}
  end

  @spec with_flag(t, flag) :: t
  def with_flag(%__MODULE__{} = cmd, flag) do
    with_flag(cmd, flag, [])
  end

  @spec with_flag(t, flag, [condition] | value) :: t
  def with_flag(%__MODULE__{} = cmd, flag, conditions) when is_binary(flag) and is_list(conditions) do
    if Enum.all?(conditions, &condition_met?/1), do: add_arg(cmd, {:flag, flag}), else: cmd
  end

  def with_flag(%__MODULE__{} = cmd, flag, value) when is_binary(flag) and is_binary(value) do
    with_flag(cmd, flag, value, [])
  end

  @spec with_flag(t, flag, value, [condition]) :: t
  def with_flag(%__MODULE__{} = cmd, flag, value, conditions)
  when is_binary(flag) and is_list(conditions) do
    if Enum.all?(conditions, &condition_met?/1), do: add_arg(cmd, {:flag, flag, value}), else: cmd
  end

  def with_opts(%__MODULE__{} = cmd, kwopts) when is_list(kwopts) do
    Enum.reduce(kwopts, cmd, fn({opt, value}, cmd) ->
      with_opt(cmd, opt, value)
    end)
  end

  def with_opt(%__MODULE__{opts: opts} = cmd, opt, value) when opt in @opts do
    %__MODULE__{cmd | opts: Map.update(opts, opt, value, fn(_) -> value end)}
  end

  def with_opt(%__MODULE__{}, opt, _) do
    raise "#{inspect opt} not supported in Cmd"
  end

  @spec with_value(t, value, [condition]) :: t
  def with_value(%__MODULE__{} = cmd, value, conditions \\ []) do
    if Enum.all?(conditions, &condition_met?/1), do: add_arg(cmd, {:value, value}), else: cmd
  end

  defp add_arg(%__MODULE__{args: args} = cmd, arg) do
    %__MODULE__{cmd | args: [arg | args]}
  end

  defp build_args(%__MODULE__{args: args}) do
    args
    |> Enum.reverse
    |> Enum.map(fn
        ({:flag, flag}) -> flag
        ({:flag, flag, value}) -> [flag, value]
        ({:value, value}) -> value
       end)
    |> List.flatten
  end

  @spec condition_met?({:if, conditional} | {:unless, conditional}) :: term
  def condition_met?({:if, conditional}) when is_function(conditional, 0) do
    conditional.()
  end

  def condition_met?({:if, {conditional, args}}) when is_function(conditional) and is_list(args) do
    :erlang.apply(conditional, args)
  end

  def condition_met?({:if, {m, f, a}})
  when is_atom(m) and is_atom(f) and is_list(a) do
    :erlang.apply(m, f, a)
  end

  def condition_met?({:if, conditional}), do: conditional

  def condition_met?({:unless, conditional}) do
    if condition_met?({:if, conditional}), do: false, else: true
  end
end

defimpl Commandable, for: Coach.Cmd.Shell do
  def to_cmd(t) do
    t
  end
end

defimpl String.Chars, for: Coach.Cmd.Shell do
  def to_string(%Coach.Cmd.Shell{} = cmd) do
    Coach.Cmd.Shell.to_string(cmd)
  end
end

defimpl Inspect, for: Coach.Cmd.Shell do
  def inspect(%Coach.Cmd.Shell{} = cmd, _opts) do
    str = String.Chars.to_string(cmd)
    "#Coach.Cmd.Shell<#{str}>"
  end
end
