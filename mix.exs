defmodule Noizu.Github.MixProject do
  use Mix.Project

  def project do
    [
      app: :noizu_github,
      name: "Noizu Labs: Github API",
      description: description(),
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end


  defp description() do
    "Github API Wrapper"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        project: "https://github.com/noizu-labs/elixir-github",
        noizu_labs: "https://github.com/noizu-labs",
        developer: "https://github.com/noizu"
      }
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {
        Noizu.Github.Application,
        [
        ]
      },
      extra_applications: [:logger, :finch, :jason]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.19"},
      {:jason, "~> 1.2"},
      {:mimic, "~> 1.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
