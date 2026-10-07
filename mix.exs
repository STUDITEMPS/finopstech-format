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
      description: "Preconfigured German number and date formatting for FinOpsTech (wrapper around Localize)",
      source_url: "https://github.com/STUDITEMPS/finopstech_format"
    ]
  end

  def application do
    [
      mod: {FinopstechFormat.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # The shipped German locale data (priv/localize/locales/de.etf) must match the
      # CLDR data of the installed Localize version, so it is pinned exactly.
      {:localize, "== 1.3.0"},
      # localize needs gettext ~> 1.0, timex (via jehovakel_ex_times, tests only) still
      # declares ~> 0.26. The apps override gettext the same way.
      {:gettext, "~> 1.0", override: true},
      {:jehovakel_ex_times, "~> 2.0", github: "STUDITEMPS/jehovakel_ex_times", only: [:test], runtime: false},
      {:tzdata, "~> 1.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.12", only: [:dev, :test], runtime: false}
    ]
  end
end
