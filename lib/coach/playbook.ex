defmodule Coach.Playbook do
  defmacro __using__(_) do
    quote do
      require Coach.Playbook
      import Coach.Playbook
    end
  end

  @type copy_opt :: {:from, Path.t} | {:to, Path.t}

  @spec copy([copy_opt]) :: Coach.Play.Copy.t
  def copy(opts) do
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)

    if to do
      quote do
        Coach.Play.Copy.new
        |> Coach.Play.Copy.from(unquote(from))
        |> Coach.Play.Copy.to(Coach.Path.path(unquote(to)))
      end
    end

  end

  def download(opts) do
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)
    unless_downloaded = Keyword.get(opts, :unless_downloaded)

    quote do
      Coach.Playbook.download(unquote(from), unquote(to), unquote(unless_downloaded))
    end
  end

  def download(from, to, unless_downloaded) do
    cmd =
      Coach.Play.Download.new()
      |> Coach.Play.Download.from(from)
      |> Coach.Play.Download.to(Coach.Path.path(to))

    cmd = if unless_downloaded, do: Coach.Play.Download.unless_downloaded(cmd), else: cmd

    cond do
      System.find_executable("curl") -> Coach.Play.Download.using_bin(cmd, :curl)
      System.find_executable("wget") -> Coach.Play.Download.using_bin(cmd, :wget)
      true -> raise "Neither Curl nor Wget found on system"
    end
  end

  def git_clone(opts) do
    repo = Keyword.get(opts, :repo)

    if to = Keyword.get(opts, :to) do
      quote do
        Coach.Play.Git.Clone.new()
        |> Coach.Play.Git.Clone.from_repo(unquote(repo))
        |> Coach.Play.Git.Clone.to_directory(Coach.Path.path(unquote(to)))
      end
    else
      quote do
        Coach.Play.Git.Clone.new() |> Coach.Play.Git.Clone.from_repo(unquote(repo))
      end
    end
  end

  def mkdir(path) do
    quote do
      Coach.Cmd.Shell.new()
      |> Coach.Cmd.Shell.with_command("mkdir")
      |> Coach.Cmd.Shell.with_flag("-p")
      |> Coach.Cmd.Shell.with_value(Coach.Path.path(unquote(path)))
    end
  end

  def play(play) when is_atom(play) do
    quote do
      :erlang.apply(Coach.Playbook, play, [])
    end
  end

  def play(module, play) when is_atom(play) do
    Code.ensure_compiled(module)
    IO.inspect("play/2")
    IO.inspect(module)
    IO.inspect(play)
    quote do
      :erlang.apply(unquote(module), unquote(play), [])
    end
  end

  def shell(str) when is_binary(str) do
    quote do
      Coach.Playbook.bash([unquote(str)])
    end
  end

  def shell(opts) when is_list(opts) do
    cmd = Keyword.get(opts, :command)
    args = Keyword.get(opts, :args)

    quote do
      unquote(args)
      |> Enum.reduce(Coach.Cmd.Shell.new(), fn(arg, cmd) ->
        Coach.Cmd.Shell.with_value(cmd, arg)
      end)
      |> Coach.Cmd.Shell.with_command(unquote(cmd))
    end
  end

  def touch(path) do
    quote do
      Coach.Cmd.Shell.new()
      |> Coach.Cmd.Shell.with_command("touch")
      |> Coach.Cmd.Shell.with_value(Coach.Path.path(unquote(path)))
    end
  end

  def bash(a) do
    Coach.Cmd.Function.from_function(fn ->
      IO.puts("Running #{inspect a}")
      %Porcelain.Result{out: out, status: status} = :erlang.apply(Porcelain, :shell, a)
      {status, out}
    end)
  end

  def build_play([do: {:__block__, _, cmds}], playbook) do
    Enum.map(cmds, fn
      ({:play, _, [play]}) ->
        quote do
          :erlang.apply(unquote(playbook), unquote(play), [])
        end
      ({func, _, args}) ->
        :erlang.apply(Coach.Playbook, func, args)
    end)
  end

  def build_play([do: play], playbook) do
    build_play([do: {:__block__, [], [play]}], playbook)
  end

  defmacro defplay(name, body) do
    ops = build_play(body, __CALLER__.module)

    quote do
      def unquote(name)() do
        Enum.reduce(unquote(ops), fn(right, left) ->
          Coach.Cmd.Combinator.then(left, right)
        end)
      end
    end
  end
end
