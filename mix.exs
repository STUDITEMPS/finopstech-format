defmodule FinopstechFormat.MixProject do
  use Mix.Project

  def project do
    [
      app: :finopstech_format,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_paths: ["lib"],
      description: "Preconfigured German number and date formatting for FinOpsTech (wrapper around CLDR)",
      source_url: "https://github.com/STUDITEMPS/finopstech_format"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_cldr_numbers, "~> 2.38"},
      {:ex_cldr_dates_times, "~> 2.24"},
      {:jason, "~> 1.4"},
      {:tzdata, "~> 1.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.12", only: [:dev, :test], runtime: false}
    ]
  end
end
