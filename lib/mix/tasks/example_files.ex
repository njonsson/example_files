defmodule Mix.Tasks.ExampleFiles do
  use Mix.Task

  @moduledoc """
  Lists all example files in your project.

  This task traverses the current working directory, looking for files that are
  intended to serve as explanatory samples of files provided by a project
  contributor or user. By default it uses `**/*{example,Example,EXAMPLE}*` as the
  file glob pattern.

  An example file may be “applied,” which means that it is copied into the same
  directory, using a file name that lacks the “example” nomenclature.

  ## Individual file status

  This task displays the current status of each of the example files it finds.
  Status is one of three values:

  * Missing —— never applied
  * Out-of-date —— applied, but currently different in content from the example
  * Up-to-date —— applied and identical in content to the example

  ## Collisions

  Your project may contain two or more example files that, when applied, use the
  same resulting file name. This constitutes a “collision.” Colliding example
  files are noted on *stderr*.

  ## Command-line options

  Any arguments you provide to the task are treated as file glob expressions.

      $ mix example_files foo bar
      Using glob pattern {foo,bar}/*{example,Example,EXAMPLE}*

      [...]
  """

  import ExampleFiles.UI,
         only: [display_collisions:   1,
                display_glob_pattern: 1,
                info:                 0,
                info:                 1,
                error:                1,
                blue:                 1,
                red:                  1,
                yellow:               1,
                underline:            1]

  @shortdoc "List all example files in your project"

  def run(filespecs) do
    {glob, noncollisions, collisions} = filespecs |> ExampleFiles.find

    glob |> display_glob_pattern

    noncollisions |> display_noncollisions
    collisions    |> display_collisions

    {glob, noncollisions, collisions}
  end

  defp display_noncollisions(noncollisions) when is_list(noncollisions) do
    info

    for {status, _, copy} <- noncollisions do
      message = case status do
        :up_to_date  ->   blue("Up to date: ")
        :out_of_date -> yellow("Out of date:")
        false        ->    red("Missing:    ")
      end
      info(message ++ underline(copy))
    end

    example_file_or_files = noncollisions |> length
                                          |> ExampleFiles.Util.pluralize("example file")
                                          |> String.capitalize
    info "#{example_file_or_files} found"
  end
end
