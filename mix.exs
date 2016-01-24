defmodule ExampleFiles.Mixfile do
  use Mix.Project

  def application do
    []
  end

  def project do
    [app:               :example_files,
     version:           version,
     description:       description,
     package:           package,
     deps:              deps,
     preferred_cli_env: [espec: :test]]
  end

  def version do
    "0.1.1"
  end

  defp deps do
    [{:espec, "~> 0.8", only: [:dev, :test]}]
  end

  defp description do
    """
    Mix tasks for managing example files in your project.

    Your project may contain files that are intended to serve as explanatory
    samples of files provided by a project contributor or user, such as
    configuration and the like. The Mix tasks provided here enable you to easily
    find, copy, and check the freshness of example files and your copies of them.
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
