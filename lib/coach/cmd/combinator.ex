defmodule Coach.Cmd.Combinator do
  alias Coach.Cmd
  @type t :: And.t | Or.t | Ensure.t

  @type combinable :: Cmd.t | t

  defmodule And do
    defstruct [first: nil, second: nil]
    @type t :: %__MODULE__{}
  end

  defmodule Or do
    defstruct [first: nil, second: nil]
    @type t :: %__MODULE__{}
  end

  defmodule Ensure do
    defstruct [first: nil, second: nil]
    @type t :: %__MODULE__{}
  end

  @spec ensure(combinable, combinable) :: t
  def ensure(first, second) do
    %Ensure{first: first |> Cmd.to_cmd, second: second |> Cmd.to_cmd}
  end

  @spec then(combinable, combinable) :: t
  def then(first, second) do
    %And{first: first |> Cmd.to_cmd, second: second |> Cmd.to_cmd}
  end

  @spec otherwise(combinable, combinable) :: t
  def otherwise(first, second) do
    %Or{first: first |> Cmd.to_cmd, second: second |> Cmd.to_cmd}
  end

  @spec run(t) :: Cmd.cmd_return
  def run(%And{first: first, second: second}) do
    result = Cmd.run(first)

    if Cmd.success?(result) do
      Cmd.run(second)
    else
      result
    end
  end

  def run(%Or{first: first, second: second}) do
    result = Cmd.run(first)

    if Cmd.success?(result) do
      result
    else
      Cmd.run(second)
    end
  end

  def run(%Ensure{first: first, second: second}) do
    result = Cmd.run(first)
    Cmd.run(second)

    result
  end
end

defimpl Commandable, for: Coach.Cmd.Combinator.And do
  @mod Coach.Cmd.Combinator.And
  def to_cmd(%@mod{} = commandable), do: commandable
end

defimpl Commandable, for: Coach.Cmd.Combinator.Or do
  @mod Coach.Cmd.Combinator.Or
  def to_cmd(%@mod{} = commandable), do: commandable
end

defimpl Commandable, for: Coach.Cmd.Combinator.Ensure do
  @mod Coach.Cmd.Combinator.Ensure
  def to_cmd(%@mod{} = commandable), do: commandable
end
