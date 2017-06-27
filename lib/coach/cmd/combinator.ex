defmodule Coach.Cmd.Combinator do
  alias Coach.Cmd
  @type t :: And.t | Or.t | Ensure.t

  @type command :: Cmd.t | t

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

  @spec ensure(command, command) :: t
  def ensure(first, second) do
    %Ensure{first: first, second: second}
  end

  @spec then(command, command) :: t
  def then(first, second) do
    %And{first: first, second: second}
  end

  @spec otherwise(command, command) :: t
  def otherwise(first, second) do
    %Or{first: first, second: second}
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
