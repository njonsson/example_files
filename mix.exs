defmodule ExampleFiles.Mixfile do
  use Mix.Project

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  def project do
    [app:               :example_files,
     version:           version,
     description:       description,
     elixir:            "~> 1.3",
     build_embedded:    Mix.env == :prod,
     start_permanent:   Mix.env == :prod,
     package:           package,
     deps:              deps,
     preferred_cli_env: [espec: :test]]
  end

  def version do
    "0.2.0"
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:dialyze,   "~> 0.2",  only: :dev},
     {:ex_doc,    "~> 0.11", only: :dev},
       {:earmark, "~> 0.2",  only: :dev},
     {:espec,     "~> 0.8",  only: [:dev, :test]}]
  end

  defp description do
    """
    Mix tasks for managing example files in your project.

    Some files in a project may be templates for unversioned files, such as
    user-specific configuration. The Mix tasks provided here find, copy, and
    check the freshness of example files and your copies of them.
    """
  end

  defp package do
    [files:       ~w(History.md License.md README.md lib mix.exs),
     maintainers: ["Nils Jonsson <example_files@nilsjonsson.com>"],
     licenses:    ["MIT"],
     links:       %{"Home"   => "https://njonsson.github.io/example_files",
                    "Source" => "https://github.com/njonsson/example_files",
                    "Issues" => "https://github.com/njonsson/example_files/issues"}]
  end
end
