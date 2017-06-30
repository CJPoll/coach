defmodule Coach.Cmd do
  alias Coach.Cmd.{Combinator, Function, Shell}
  alias Coach.Cmd.Combinator.{And, Or, Ensure}

  defdelegate to_cmd(commandable), to: Commandable

  @type t :: Combinator.t | Shell.t | Function.t | Commandable.t
  @type return :: {String.t, integer} | {:error, term} | no_return | term

  @spec run(t) :: Commandable.return
  def run(%Coach.Cmd.Combinator.Or{} = combinator), do: Combinator.run(combinator)
  def run(%Coach.Cmd.Combinator.And{} = combinator), do: Combinator.run(combinator)
  def run(%Coach.Cmd.Combinator.Ensure{} = combinator), do: Combinator.run(combinator)
  def run(commandable) do
    commandable
    |> to_cmd
    |> do_run
  end

  def do_run(%And{} = cmd), do: Combinator.run(cmd)
  def do_run(%Or{} = cmd), do: Combinator.run(cmd)
  def do_run(%Ensure{} = cmd), do: Combinator.run(cmd)
  def do_run(%Shell{} = cmd), do: Shell.run(cmd)
  def do_run(%Function{} = cmd), do: Function.run(cmd)

  def return_value({:ok, term}), do: term
  def return_value({:error, term}), do: term
  def return_value({str, _}) when is_binary(str), do: str
  def return_value(val), do: val

  def success?({str, 0}) when is_binary(str), do: true
  def success?({str, _}) when is_binary(str), do: false
  def success?(tuple) when is_tuple(tuple) and elem(tuple, 0) == :error, do: false
  def success?(:error), do: false
  def success?(_), do: true
end

defprotocol Commandable do
  alias Coach.Cmd.{Function, Shell}

  @spec to_cmd(t) :: Shell.t | Function.t
  def to_cmd(t)
end

defimpl Commandable, for: Any do
  def to_cmd(t) do
    raise "Commandable is not implemented for #{inspect t}"
  end
end
