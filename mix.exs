defmodule Coach.Mixfile do
  use Mix.Project

  def project do
    [app: :coach,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp aliases do
    ["compile": ["compile --warnings-as-errors"]]
     #"test": ["test", "dialyzer --halt-exit-status"]]
  end

  defp deps do
    [{:dialyxir, "~> 0.5.0"},
     {:porcelain, "~> 2.0.0"}]
  end
end
