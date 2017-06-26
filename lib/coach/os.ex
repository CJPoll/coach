defmodule Coach.Os do
  @type os :: :mac | :debian | :redhat | :linux | :unknown

  def current_os() do
    os = :os.type

    cond do
      {:unix, :darwin} == os -> :mac
      {:unix, :linux} == os and has_yum?() -> :redhat
      {:unix, :linux} == os and has_apt?() -> :debian
      {:unix, :linux} == os -> :linux
      true -> :unkown
    end
  end

  def has_yum?() do
    has_bin?("yum")
  end

  def has_apt?() do
    has_bin?("apt-get")
  end

  def has_bin?(bin) do
    case System.cmd("which", [bin]) do
      {_, 0} -> true
      _ -> false
    end
  end
end
