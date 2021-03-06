defmodule Concourse.MixProject do
  use Mix.Project

  def project do
    [
      app: :concourse,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: :transitive,
        flags: [:unmatched_returns,:error_handling,:race_conditions, :no_opaque],
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:briefly, :yamerl],
      extra_applications: [:logger],
      mod: {Concourse.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yaml_elixir, ">= 0.0.0"},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:briefly, "~> 0.3", only: [:dev, :test], runtime: false}
    ]
  end
end
