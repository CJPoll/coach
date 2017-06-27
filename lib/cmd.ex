defmodule Coach.Cmd do
  alias Coach.Cmd.{Function, Shell}

  @type t :: Shell.t | Function.t | Commandable.t
  @type return :: {String.t, integer} | {:ok, term} | {:error, term}

  @spec run(Commandable.t) :: Commandable.return

  def run(commandable) do
    commandable
    |> Commandable.to_cmd
    |> do_run
  end

  def do_run(%Shell{} = cmd) do
    Shell.run(cmd)
  end

  def do_run(%Function{} = cmd) do
    Function.run(cmd)
  end

  def return_value({:ok, term}), do: term
  def return_value({:error, term}), do: term
  def return_value({str, _}) when is_binary(str), do: str

  def success?({str, 0}) when is_binary(str), do: true
  def success?({str, _}) when is_binary(str), do: false
  def success?({:ok, _}), do: true
  def success?({:error, _}), do: false
end

defprotocol Commandable do
  alias Coach.Cmd.{Function, Shell}

  @spec to_cmd(t) :: Shell.t | Function.t
  def to_cmd(t)
end
