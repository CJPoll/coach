defmodule Coach.Play.Download do
  alias Coach.Cmd

  @type opts :: [{:unless_exists, boolean}]

  @spec cmd(URI.t, Path.t, opts)
  :: Cmd.t
  def cmd(uri, local_path, opts \\ []) do
    if Keyword.get(opts, :unless_exists, false) and File.exists?(local_path) do
      Cmd.new()
      |> Cmd.with_command("echo")
      |> Cmd.with_value("Not downloading #{URI.to_string(uri)}. #{local_path} already exists")
    else
      Coach.File.download(uri, local_path)
    end
  end
end
