defmodule Mix.Tasks.ExampleFiles do
  @dialyzer :no_undefined_callbacks
  use Mix.Task

  @moduledoc """
  Lists example files in your project and shows the status of each.

  This task traverses the current working directory, looking for files that are
  intended to serve as illustrative samples of files provided by a project
  contributor or user.

  ```console
  $ mix example_files
  Using fileglob **/*{example,Example,EXAMPLE}*

  Missing:     spec/fixtures/collisions/file2
  Missing:     spec/fixtures/no_collisions/file

  2 example files

  Collision detected! spec/fixtures/collisions/file1
  • spec/fixtures/collisions/EXAMPLE-file1
  • spec/fixtures/collisions/file1.example
  ```

  ## Individual file status

  This task displays the current status of each of the example files it finds.
  The status of a copy is one of three values:

  * Missing — not present
  * Identical — present and identical in content to the example
  * Out-of-date — present, but currently different in content from the example

  ## Fileglobs

  The pattern `**/*{example,Example,EXAMPLE}*` is used by default to search for
  example files. You can further restrict the search in `mix example_files` and
  its subtasks by specifying one or paths or patterns that will be combined with
  the example-files pattern:

  ```console
  $ mix example_files doc log
  Using fileglob {doc,log}/**/*{example,Example,EXAMPLE}*
  ```

  ## Ignored paths

  The following paths are ignored by default in searching for example files:

  * _.git/_
  * _\_build/_
  * _deps/_
  * _node_modules/_
  * _tmp/_

  You can override this default in `mix example_files` and its subtasks by
  specifying one or more `--ignore` or `-i` options:

  ```console
  $ mix example_files --ignore spec --ignore log
  Using fileglob **/*{example,Example,EXAMPLE}*
  ```

  ## Collisions

  An example file may be “pulled,” which means that it is copied into the same
  directory, using a file name that lacks the “example” nomenclature. A project
  may contain two or more example files that, if they were both pulled, would use
  the same resulting file name. This constitutes a “collision,” which is always
  prevented; colliding example files are never operated on, but are displayed on
  _stderr_.

  ## Verbose output

  You can get more information about what `mix example_files` and its subtasks
  are doing by specifying the `--verbose` or `-v` option.
  """ |> String.replace(~r/\s+$/, "")
  # TODO: Use String.trim_trailing/1 when targeting Elixir >= v1.3

  @shortdoc "Lists example files in your project"

  alias ExampleFiles.{English,Options,UI}
  alias IO.ANSI

  @spec run([binary]) :: [pid]
  @doc false
  def run(arguments) do
    :example_files |> Application.ensure_all_started

    {:ok, options_pid} = Options.start_link(arguments)
    options_pid |> Options.fileglobs |> display_fileglobs

    {:ok, example_files_pid} = ExampleFiles.start_link(options: options_pid)
    noncollisions = example_files_pid |> display_noncollisions
    example_files_pid |> display_collisions

    noncollisions
  end

  @spec display_collisions(pid) :: [pid]
  @doc false
  def display_collisions(example_files_pid) do
    for example_files <- example_files_pid |> ExampleFiles.collisions do
      UI |> UI.error
      path_when_pulled = example_files |> List.first
                                       |> ExampleFiles.File.path_when_pulled
                                       |> UI.underline
      UI |> UI.error([UI.red("Collision detected!"), " ", path_when_pulled])
      for example_file <- example_files do
        path = example_file |> ExampleFiles.File.path
        UI |> UI.error(["• ", UI.underline(path)])
      end

      example_files
    end
  end

  @spec display_fileglobs([binary]) :: ANSI.ansidata

  @doc false
  def display_fileglobs([fileglob]) do
    UI |> UI.info(["Using fileglob ", UI.underline(fileglob)])
  end

  @doc false
  def display_fileglobs(fileglobs) do
    list = fileglobs |> Enum.map(&(&1 |> UI.underline
                                      |> ANSI.format_fragment
                                      |> IO.chardata_to_string))
                     |> English.list
    UI |> UI.info(["Using fileglobs ", list])
  end

  @spec display_noncollisions(pid) :: [pid]
  defp display_noncollisions(example_files_pid) do
    noncollisions = example_files_pid |> ExampleFiles.noncollisions
    if 0 < length(noncollisions), do: UI |> UI.info

    for file <- noncollisions do
      message = case file |> ExampleFiles.File.status do
        :identical   -> "Identical:  " |> UI.green
        :out_of_date -> "Out of date:" |> UI.yellow
        :missing     -> "Missing:    " |> UI.yellow
      end
      UI |> UI.info([message,
                     " ",
                     UI.underline(ExampleFiles.File.path_when_pulled(file))])
    end

    UI |> UI.info
    example_file_or_files = noncollisions |> length
                                          |> English.pluralize("example file")
                                          |> String.capitalize
    UI |> UI.info(example_file_or_files)

    noncollisions
  end
end
