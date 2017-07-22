defmodule Coach.Playbook do
  defmacro __using__(_) do
    quote do
      require Coach.Playbook
      import Coach.Playbook
    end
  end

  @type copy_opt :: {:from, Path.t} | {:to, Path.t}

  def apply(module, function, args, caller) do
    mod = Macro.expand_once(module, caller)

    quote do
      Coach.Cmd.Function.from_function(unquote(mod), unquote(function), unquote(args))
    end
  end

  def copy(opts, _caller) do
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)

    if to do
      quote do
        Coach.Play.Copy.new
        |> Coach.Play.Copy.from(Coach.Path.path(unquote(from)))
        |> Coach.Play.Copy.to(Coach.Path.path(unquote(to)))
        |> Coach.Cmd.to_cmd
      end
    end

  end

  def download(opts, _caller) do
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

  def extract(opts, _caller) do
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)
    keep_newer_files = Keyword.get(opts, :keep_newer_files)
    strip_components = Keyword.get(opts, :strip_components)

    quote do
      Coach.Playbook.extract(unquote(from), unquote(to), unquote(keep_newer_files), unquote(strip_components))
    end
  end

  def extract(from, to, keep_newer_files, strip_components) do
    alias Coach.Play.Extract
    e =
      Extract.new()
      |> Extract.from(Coach.Path.path(from))
      |> Extract.to(Coach.Path.path(to))
    
    e = if keep_newer_files, do: Extract.keep_newer_files(e), else: e
    if strip_components, do: Extract.strip_components(e, strip_components), else: e
  end

  def git_clone(opts, _caller) do
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

  def install(opts, _caller) do
    packages = Keyword.get(opts, :packages, [])
    packages = Keyword.get_values(opts, :package) ++ packages
    os = Keyword.get(opts, :on)

    quote do
      Enum.reduce(unquote(packages), Coach.Play.Package.Install.new(), fn(package, installer) ->
        Coach.Play.Package.Install.install(installer, unquote(os), package)
      end)
    end
  end

  def mkdir(path, _caller) do
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

  def play(module, play, caller) when is_atom(play) do
    module
    |> Macro.expand_once(caller)
    |> Code.ensure_compiled

    quote do
      :erlang.apply(unquote(module), unquote(play), [])
    end
  end

  def shell(str, _caller) when is_binary(str) do
    quote do
      Coach.Playbook.bash([unquote(str)])
    end
  end

  def shell(opts, _caller) when is_list(opts) do
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

  def touch(path, _caller) do
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

  def build_play([do: {:__block__, _, cmds}], caller) do
    module = caller.module
    Enum.map(cmds, fn
      ({:play, _, [play]}) ->
        quote do
          :erlang.apply(unquote(module), unquote(play), [])
        end
      ({func, _, args}) ->
        :erlang.apply(Coach.Playbook, func, args ++ [caller])
    end)
  end

  def build_play([do: play], caller) do
    build_play([do: {:__block__, [], [play]}], caller)
  end

  defmacro defplay(name, body) do
    ops = build_play(body, __CALLER__)

    quote do
      def unquote(name)(opts \\ []) do
        user = Keyword.get(opts, :run_as, nil)

        ops = unquote(ops)

        ops
        |> Enum.map(fn
             (%Coach.Cmd.Shell{} = op) -> if user, do: Coach.Cmd.Shell.as_user(op, user), else: op
             (op) -> op
           end)
       |> Enum.reduce(fn(right, left) -> Coach.Cmd.Combinator.then(left, right) end)
      end
    end
  end
end
