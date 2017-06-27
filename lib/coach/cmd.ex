defmodule Coach.Cmd do
  defmodule Function do
    defstruct [module: nil, function: nil, args: [], func: nil]
  end

  @type arg0 :: String.t
  @type argument :: flag | value
  @type command :: String.t
  @type directory :: String.t
  @type env_var_name :: String.t
  @type env_var_value :: String.t
  @type flag :: String.t # "-flag", "-f"
  @type status_code :: non_neg_integer
  @type value :: String.t
  @type cmd_return :: {term, status_code}

  @typep arguments :: [argument]
  @type env :: [{env_var_name, env_var_value}]
  @type maybe(t) :: t | nil

  @typep opts :: %{
    optional(:into) => Collectable.t,
    optional(:cd) => directory,
    optional(:env) => [env],
    optional(:arg0) => arg0,
    optional(:stderr_to_stdout) => boolean
  }

  @type cmd :: %__MODULE__{
    command: maybe(command),
    args: arguments,
    opts: opts
  }

  @typep anon_func :: %Function{
    module: nil,
    function: nil,
    args: [],
    func: ((...) -> term)
  }

  @typep mfa_func :: %Function{
    module: module,
    function: atom,
    args: [term],
    func: nil
  }

  @type func :: anon_func | mfa_func

  @type t :: cmd | func | Coach.Cmd.Combinator.t

  @opts [:into, :cd, :env, :arg0, :stderr_to_stdout, :parallelism]

  defstruct [args: [], background: false, command: nil, opts: %{}]

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

  @spec background(t) :: t
  def background(%__MODULE__{} = cmd) do
    %__MODULE__{cmd | background: true}
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

  @spec from_function((() -> term)) :: Cmd.t
  def from_function(func) do
    %Function{func: func}
  end

  @spec from_function(module, atom, [term]) :: Cmd.t
  def from_function(module, function, args) do
    %Function{module: module, function: function, args: args}
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

  @spec run(t) :: cmd_return
  def run(%Function{module: module, function: function, args: args})
  when is_atom(module) and module != nil
  and is_atom(function) and function != nil
  and is_list(args) do
    result = :erlang.apply(module, function, args)
    {result, 0}
  end

  def run(%Function{func: func}) when func != nil do
    result = func.()
    {result, 0}
  end

  def run(%__MODULE__{command: nil}) do
    raise "Cmd command has not ben set!"
  end

  def run(%__MODULE__{} = cmd) do
    IO.puts("Running: #{__MODULE__.to_string(cmd)}")

    do_run(cmd)
  end

  def run(command) do
    __MODULE__.Combinator.run(command)
  end

  def do_run(%__MODULE__{command: command, opts: opts} = cmd) do
    System.cmd(command, build_args(cmd), Map.to_list(opts))
  end

  @spec status_code({Collectable.t, status_code}) :: status_code
  def status_code({_, status_code}), do: status_code

  @spec to_string(t) :: String.t
  def to_string(%__MODULE__{command: command} = cmd) do
    String.strip("#{command} #{arg_string(cmd)}")
  end

  @spec with_command(t, command) :: t
  def with_command(%__MODULE__{args: args, opts: opts}, command) do
    %__MODULE__{command: command, args: args, opts: opts}
  end

  @spec with_flag(t, flag) :: t
  def with_flag(%__MODULE__{} = cmd, flag) when is_binary(flag) do
    add_arg(cmd, {:flag, flag})
  end

  @spec with_flag(t, flag, value) :: t
  def with_flag(%__MODULE__{} = cmd, flag, value) when is_binary(flag) and is_binary(value) do
    add_arg(cmd, {:flag, flag, value})
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

  @spec with_value(t, value) :: t
  def with_value(%__MODULE__{} = cmd, value) when is_binary(value) do
    add_arg(cmd, {:value, value})
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
end

defimpl String.Chars, for: Coach.Cmd do
  def to_string(%Coach.Cmd{} = cmd) do
    Coach.Cmd.to_string(cmd)
  end
end

defimpl Inspect, for: Coach.Cmd do
  def inspect(%Coach.Cmd{} = cmd, _opts) do
    str = String.Chars.to_string(cmd)
    "#Coach.Cmd<#{str}>"
  end
end
