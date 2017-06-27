defmodule Coach.File do
  alias Coach.Cmd

  @typep download_bin :: :curl | :wget
  @type file_type :: :dir | :file

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

    Cmd.new
    |> Cmd.with_command("curl")
    |> Cmd.with_flag("--location")
    |> Cmd.with_flag("-o", path)
    |> Cmd.with_flag("--create-dirs")
    |> Cmd.with_value(url)
  end

  def download_cmd(:wget, %URI{} = uri, path) do
    url = URI.to_string(uri)

    Cmd.new
    |> Cmd.with_command("wget")
    |> Cmd.with_flag("-O", path)
    |> Cmd.with_value(url)
  end

  @spec ensure_deleted(Path.t) :: Cmd.t
  def ensure_deleted(path) do
    Cmd.from_function(fn ->
      if File.exists?(path) do
        Cmd.new()
        |> Cmd.with_command("rm")
        |> Cmd.with_flag("-r")
        |> Cmd.with_flag("-f")
        |> Cmd.with_value(path)
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
    Cmd.new
    |> Cmd.with_command("tar")
    |> Cmd.with_flag("-x")
    |> Cmd.with_flag("-v")
    |> Cmd.with_flag("-f")
    |> Cmd.with_value(tarball)
  end
end
