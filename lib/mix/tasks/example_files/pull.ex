defmodule Mix.Tasks.ExampleFiles.Pull do
  @dialyzer :no_undefined_callbacks
  use Mix.Task

  @moduledoc """
  Pulls into effect example files in your project by making copies of them using
  a file name that lacks the “example” nomenclature.

  See the help for `Mix.Tasks.ExampleFiles` in order to learn about example files
  and the command-line options available to all related tasks.
  """ |> String.replace(~r/\s+$/, "")
  # TODO: Use String.trim_trailing/1 when targeting Elixir >= v1.3

  @shortdoc "Copies into effect example files in your project"

  # TODO: Use `alias ExampleFiles.{Options,UI}` when targeting Elixir >= v1.2
  alias ExampleFiles.Options
  alias ExampleFiles.UI

  @spec run([binary]) :: [pid]
  @doc false
  def run(arguments) do
    :example_files |> Application.ensure_all_started

    {:ok, options_pid} = Options.start_link(arguments)
    options_pid |> Options.fileglobs |> Mix.Tasks.ExampleFiles.display_fileglobs

    {:ok, example_files_pid} = ExampleFiles.start_link(options: options_pid)
    pulled = example_files_pid |> pull_noncollisions

    example_files_pid |> Mix.Tasks.ExampleFiles.display_collisions

    pulled
  end

  @spec pull_noncollisions(GenServer.server) :: [pid]
  defp pull_noncollisions(example_files_pid) do
    results = example_files_pid |> ExampleFiles.noncollisions
                                |> Enum.map(fn(file) ->
      case file |> ExampleFiles.File.pull do
        {:ok, :copied}    -> {:copied, file}
        {:ok, :identical} -> nil
        {:error, error}   -> {:error, {error, file}}
      end
    end) |> Enum.reject(&is_nil/1)
    if 0 < length(results), do: UI |> UI.info

    pulled = results |> Keyword.get_values(:copied)
    for file <- pulled do
      UI |> UI.info([UI.green("Copied"),
                     " ",
                     UI.underline(ExampleFiles.File.path(file)),
                     " to ",
                     UI.underline(ExampleFiles.File.path_when_pulled(file))])
    end

    for {error, file} <- Keyword.get_values(results, :error) do
      UI |> UI.error([UI.red("#{error |> :file.format_error}!"),
                     " ",
                     UI.underline(ExampleFiles.File.path_when_pulled(file))])
    end

    pulled
  end
end
