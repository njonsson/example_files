defmodule ExampleFiles.Mixfile do
  use Mix.Project

  def application do
    []
  end

  def project do
    [app:         :example_files,
     version:     "0.1.0",
     description: description,
     package:     package,
     deps:        deps]
  end

  defp deps do
    []
  end

  defp description do
    """
    Mix tasks for managing example files in your project.

    Your project may contain files that serve as examples to the developer, or
    templates. Such files are intended to be copied by the developer for use as
    configuration and the like. The mix tasks provided here enable you to easily
    find, copy, and check the freshness of example files and your copies of them.
    """
  end

  defp package do
    [files:       ~w(History.md License.md README.md lib mix.exs),
     maintainers: ["Nils Jonsson <example_files@nilsjonsson.com>"],
     licenses:    ["MIT"],
     links:       %{"Home"   => "https://njonsson.github.com/example_files",
                    "Source" => "https://github.com/njonsson/example_files",
                    "Issues" => "https://github.com/njonsson/example_files/issues"}]
  end
end
