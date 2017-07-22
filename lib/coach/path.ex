defmodule Coach.Path do
  def path({:priv, path}) do
    Path.join([File.cwd!(), "priv", path(path)])
  end

  def path({:system, var}) do
    System.get_env(var)
  end

  def path({:tmp, path}) do
    Path.join([System.tmp_dir!, path(path)])
  end

  def path({:home, path}) do
    Path.join([System.user_home!, path(path)])
  end

  def path({:home, user, path}) do
    Path.join([home_for(user), path(path)])
  end

  def path(path) when is_binary(path), do: path

  defp home_for(user) do
    %Porcelain.Result{out: home, status: 0} = Porcelain.shell("echo ~#{user}")
    String.trim(home, "\n")
  end
end
