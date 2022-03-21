defmodule ExPostcss.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/tomciopp/ex_postcss"

  def project do
    [
      app: :ex_postcss,
      version: @version,
      elixir: "~> 1.12",
      deps: deps(),
      description: "Mix tasks for invoking postcss-cli",
      docs: [
        main: "ExPostcss",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"]
      ],
      package: [
        links: %{
          "GitHub" => @source_url,
          "postcss-cli" => "https://github.com/postcss/postcss-cli"
        },
        licenses: ["MIT"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExPostcss, []},
      env: [default: []]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
