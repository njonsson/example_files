defmodule ExampleFiles.Mixfile do
  use Mix.Project

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod:          {ExampleFiles.Application, []},
     registered:   [ExampleFiles.UI]]
  end

  def project do
    [app:               :example_files,
     version:           version(),
     description:       description(),
     elixir:            "~> 1.0",
     build_embedded:    Mix.env == :prod,
     start_permanent:   Mix.env == :prod,
     package:           package(),
     deps:              deps(),
     preferred_cli_env: [espec: :test],
     docs:              [extras: ["README.md":  [filename: "about",
                                                 title: "About example_files"],
                                  "License.md": [filename: "license",
                                                 title: "Project license"]],
                                  # TODO: Figure out why ExDoc chokes on this
                                  # "History.md": [filename: "history",
                                  #                title: "Project history"]],
                         main: "about"]]
  end

  def version, do: "1.0.0"

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
    [{:dialyxir,  "~> 0.5",  only: :dev},
     {:ex_doc,    "~> 0.14", only: :dev},
       {:earmark, "~> 1.0",  only: :dev},
     {:espec,     "~> 1.2",  only: [:dev, :test]}]
  end

  defp description, do: "Mix tasks for managing example files in your project."

  defp package do
    [files:       ~w(History.md License.md README.md lib mix.exs),
     maintainers: ["Nils Jonsson <example_files@nilsjonsson.com>"],
     licenses:    ["MIT"],
     links:       %{"Home"   => "https://njonsson.github.io/example_files",
                    "Source" => "https://github.com/njonsson/example_files",
                    "Issues" => "https://github.com/njonsson/example_files/issues"}]
  end
end
