defmodule Coach.File do
  alias Coach.Cmd

  @typep download_bin :: :curl | :wget

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
