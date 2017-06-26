defmodule Coach.Cmd.Combinator do
  alias Coach.Cmd
  @type t :: And.t | Or.t

  @type command :: Cmd.t | t

  defmodule And do
    defstruct [first: nil, second: nil]
    @type t :: %__MODULE__{}
  end

  defmodule Or do
    defstruct [first: nil, second: nil]
    @type t :: %__MODULE__{}
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

    case Cmd.status_code(result) do
      0 -> Cmd.run(second)
      _ -> result
    end
  end

  def run(%Or{first: first, second: second}) do
    result = Cmd.run(first)

    case Cmd.status_code(result) do
      0 -> result
      _ -> Cmd.run(second)
    end
  end
end
