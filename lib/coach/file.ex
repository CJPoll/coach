defmodule Coach.File do
  alias Coach.Cmd.{Function, Shell}

  @typep download_bin :: :curl | :wget
  @type file_type :: :dir | :file

  @spec copy(Path.t, Path.t) :: Cmd.t
  def copy(from, to) do
    Function.from_function(File, :cp, [from, to])
  end

  @spec download(URI.t, Path.t)
  :: Cmd.t
  def download(%URI{} = uri, path) do
    download_cmd(download_bin(), uri, path)
  end

  def download(uri, _) when is_binary(uri) do
    raise "Coach.File.download/2 requires a %URI{}, not the URL as a string."
  end

  @spec download_bin()
  :: download_bin
  def download_bin() do
    cond do
      Coach.Os.has_bin?("curl") -> :curl
      Coach.Os.has_bin?("wget") -> :wget
    end
  end

  @spec download_cmd(download_bin, URI.t, Path.t)
  :: Cmd.t
  def download_cmd(:curl, %URI{} = uri, path) do
    url = URI.to_string(uri)

    Shell.new
    |> Shell.with_command("curl")
    |> Shell.with_flag("--location")
    |> Shell.with_flag("-o", path)
    |> Shell.with_flag("--create-dirs")
    |> Shell.with_value(url)
  end

  def download_cmd(:wget, %URI{} = uri, path) do
    url = URI.to_string(uri)

    Shell.new
    |> Shell.with_command("wget")
    |> Shell.with_flag("-O", path)
    |> Shell.with_value(url)
  end

  @spec ensure_deleted(Path.t) :: Cmd.t
  def ensure_deleted(path) do
    Function.from_function(fn ->
      if File.exists?(path) do
        Shell.new()
        |> Shell.with_command("rm")
        |> Shell.with_flag("-r")
        |> Shell.with_flag("-f")
        |> Shell.with_value(path)
        |> Cmd.run
      end
    end)
  end

  @spec ensure_exists(Path.t, file_type) :: Cmd.t
  def ensure_exists(path, :dir) do
    Cmd.from_function(fn ->
      unless File.exists?(path) do
        File.mkdir_p(path)
      end
    end)
  end

  @spec extract(Path.t)
  :: Cmd.t
  def extract(tarball) do
    Shell.new
    |> Shell.with_command("tar")
    |> Shell.with_flag("-x")
    |> Shell.with_flag("-v")
    |> Shell.with_flag("-f")
    |> Shell.with_value(tarball)
  end
end
