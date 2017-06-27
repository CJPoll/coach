defmodule Coach.Cmd.Function do
  defstruct [module: nil, function: nil, args: nil, func: nil]

  @type anon_func :: %__MODULE__{
    module: nil,
    function: nil,
    args: [term],
    func: ((...) -> term)
  }

  @type mfa_func :: %__MODULE__{
    module: module,
    function: atom,
    args: [term],
    func: nil
  }

  @type t :: anon_func | mfa_func

  @spec from_function((() -> term)) :: t
  def from_function(func) when is_function(func) do
    %__MODULE__{func: func}
  end

  @spec from_function(((...) -> term), [term]) :: t
  def from_function(func, args)
  when is_function(func) and is_list(args) do
    %__MODULE__{func: func, args: args}
  end

  @spec from_function(module, atom, [term]) :: t
  def from_function(module, function, args) do
    %__MODULE__{module: module, function: function, args: args}
  end

  @spec run(t) :: {:ok, term} | {:error, term}
  def run(%__MODULE__{module: module, function: function, args: args})
  when is_atom(module) and module != nil
  and is_atom(function) and function != nil
  and is_list(args) do
    :erlang.apply(module, function, args)
  end

  def run(%__MODULE__{func: func, args: args})
  when is_function(func) and is_list(args) do
    result = :erlang.apply(func, args)
    {result, 0}
  end
end
