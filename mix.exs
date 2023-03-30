defmodule Iracing.MixProject do
  use Mix.Project

  def project do
    [
      app: :iracing,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [
        api:
          case Mix.env() do
            :test -> Iracing.Api.Fake
            _ -> Iracing.Api.Http
          end
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.5"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.4"}
    ]
  end
end
