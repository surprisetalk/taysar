defmodule Taysar.MixProject do
  use Mix.Project

  def project do
    [
      app: :taysar,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :poison, :httpoison, :earmark, :sitemap, :postgrex],
      mod: {Taysar.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:postgrex, "~> 0.14"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"},
      {:earmark, "~> 1.3.2" },
      {:sitemap, "~> 1.1"}
    ]
  end
end
