defmodule Mix.Tasks.ExampleFiles.Clean do
  @dialyzer :no_undefined_callbacks
  use Mix.Task

  @moduledoc """
  Cleans example files in your project by deleting your copies of them.

  See the help for `Mix.Tasks.ExampleFiles` in order to learn about example files
  and the command-line options available to all related tasks.
  ```
  """ |> String.replace(~r/\s+$/, "")
  # TODO: Use String.trim_trailing/1 when targeting Elixir >= v1.3

  @shortdoc "Deletes copies of example files from your project"

  alias ExampleFiles.{Options,UI}

  @spec run([binary]) :: [pid]
  @doc false
  def run(arguments) do
    :example_files |> Application.ensure_all_started

    {:ok, options_pid} = Options.start_link(arguments)
    options_pid |> Options.fileglobs |> Mix.Tasks.ExampleFiles.display_fileglobs

    {:ok, example_files_pid} = ExampleFiles.start_link(options: options_pid)
    cleaned = example_files_pid |> clean_noncollisions

    example_files_pid |> Mix.Tasks.ExampleFiles.display_collisions

    cleaned
  end

  @spec clean_noncollisions(GenServer.server) :: [pid]
  defp clean_noncollisions(example_files_pid) do
    noncollisions = example_files_pid |> ExampleFiles.noncollisions

    results = noncollisions |> Enum.map(fn(file) ->
      case file |> ExampleFiles.File.clean do
        {:ok, :deleted} -> {:deleted, file}
        {:ok, :enoent}  -> nil
        {:error, error} -> {:error, {error, file}}
      end
    end) |> Enum.reject(&is_nil/1)
    if 0 < length(results), do: UI |> UI.info

    cleaned = results |> Keyword.get_values(:deleted)
    for file <- cleaned do
      UI |> UI.info([UI.yellow("Deleted"),
                     " ",
                     UI.underline(ExampleFiles.File.path_when_pulled(file))])
    end

    for {error, file} <- Keyword.get_values(results, :error) do
      UI |> UI.error([UI.red("#{error |> :file.format_error}!"),
                      " ",
                      UI.underline(ExampleFiles.File.path_when_pulled(file))])
    end

    cleaned
  end
end
