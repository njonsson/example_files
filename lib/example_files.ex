defmodule ExampleFiles do
  @moduledoc """
  A `GenServer` that provides access to the `ExampleFiles.File` processes for a
  project.
  """

  defmodule State do
    @moduledoc """
    A struct encapsulating the state of an `ExampleFiles` process.
    """

    @enforce_keys [:options]
    defstruct [:all, :options]
  end

  use GenServer

  alias ExampleFiles.{English,Options,UI}
  alias IO.ANSI

  # Client API

  # TODO: Update this spec using the new `keyword` type under Elixir v1.3
  # @spec start_link([%State{}] | [options: GenServer.server], keyword) :: GenServer.on_start
  @spec start_link([%State{}] | [options: GenServer.server], [{atom, any}]) :: GenServer.on_start

  @doc """
  Starts an `ExampleFiles` process, linked to the current process, with the
  specified `arguments` and `options`.

  The process exits if `arguments` does not contain an `ExampleFiles.State`.
  """
  def start_link([%State{}]=arguments, options) do
    __MODULE__ |> GenServer.start_link(arguments, options)
  end

  @spec start_link([options: GenServer.server]) :: GenServer.on_start
  @doc """
  Starts an `ExampleFiles` process, linked to the current process, with the
  specified `example_files_options` (`ExampleFiles.Options`).
  """
  def start_link([options: example_files_options]) do
    [%State{options: example_files_options}] |> start_link([])
  end

  @spec all(GenServer.server, timeout) :: [pid]
  @doc """
  Returns an `ExampleFiles.File` PID for each example file in the `System.cwd!`,
  spawning such processes if they are not already running.

  ## Examples

      iex> {:ok, options} = ExampleFiles.Options.start_link(~w(--ignore EXAMPLE-file1))
      ...> {:ok, example_files} = ExampleFiles.start_link(options: options)
      ...> File.cd!("spec/fixtures/collisions", fn -> example_files |> ExampleFiles.all end) |> Enum.map(&ExampleFiles.File.path/1) |> Enum.sort
      ["file1.example", "file2.example"] |> Enum.sort

      iex> {:ok, options} = ExampleFiles.Options.start_link([])
      ...> {:ok, example_files} = ExampleFiles.start_link(options: options)
      ...> File.cd! "spec/fixtures/empty", fn -> example_files |> ExampleFiles.all end
      []
  """
  def all(example_files, timeout \\ 5000) do
    example_files |> GenServer.call({:all}, timeout)
  end

  @spec collisions(GenServer.server, timeout) :: [pid]
  @doc """
  Finds subsets of `all` that share a value for
  `ExampleFiles.File.path_when_pulled`.

  ## Examples

      iex> {:ok, options} = ExampleFiles.Options.start_link([])
      ...> {:ok, example_files} = ExampleFiles.start_link(options: options)
      ...> File.cd!("spec/fixtures/collisions", fn -> example_files |> ExampleFiles.collisions end) |> Enum.map(fn(collision_group) -> collision_group |> Enum.map(&ExampleFiles.File.path/1) |> Enum.sort end) |> Enum.sort
      [~w(EXAMPLE-file1 file1.example)] |> Enum.map(&Enum.sort/1) |> Enum.sort

      iex> {:ok, options} = ExampleFiles.Options.start_link([])
      ...> {:ok, example_files} = ExampleFiles.start_link(options: options)
      ...> File.cd!("spec/fixtures/no_collisions", fn -> example_files |> ExampleFiles.collisions end) |> Enum.map(fn(collision_group) -> collision_group |> Enum.map(&ExampleFiles.File.path/1) |> Enum.sort end) |> Enum.sort
      []
  """
  def collisions(example_files, timeout \\ 5000) do
    example_files |> GenServer.call({:collisions}, timeout)
  end

  @spec noncollisions(GenServer.server, timeout) :: [pid]
  @doc """
  Filters `all` for items having a unique value for
  `ExampleFiles.File.path_when_pulled`.

  ## Examples

      iex> {:ok, options} = ExampleFiles.Options.start_link([])
      ...> {:ok, example_files} = ExampleFiles.start_link(options: options)
      ...> File.cd!("spec/fixtures/collisions", fn -> example_files |> ExampleFiles.noncollisions end) |> Enum.map(&ExampleFiles.File.path/1) |> Enum.sort
      ["file2.example"] |> Enum.sort
  """
  def noncollisions(example_files, timeout \\ 5000) do
    example_files |> GenServer.call({:noncollisions}, timeout)
  end

  defp all_impl(%{all: nil, options: options}=state) do
    UI |> UI.autoflush(false)

    fileglobs  = options |> Options.fileglobs
    is_verbose = options |> Options.verbose?
    all = fileglobs |> Enum.flat_map(fn(fileglob) ->
      unfiltered = for filename <- fileglob |> Path.wildcard(match_dot: true) do
        if is_verbose do
          UI |> UI.info(["Fileglob ",
                         UI.underline(fileglob),
                         " found file ",
                         UI.underline(filename)])
        end

        if filename |> interesting?(options) do
          filename |> start_link_file_for
        else
          nil
        end
      end
      unfiltered |> Enum.reject(&is_nil/1)
    end)
    if is_verbose do
      if 0 < length(all), do: UI |> UI.info_insert_at(0)
    end

    UI |> UI.autoflush(true)

    %{state | all: all}
  end

  defp all_impl(state),do: state

  # Server callbacks

  def init([%State{}=state]), do: {:ok, state}

  def init(_), do: {:stop, "Invalid state"}

  def handle_call({:all}, _from, state) do
    %{all: all}=new_state = state |> all_impl

    {:reply, all, new_state}
  end

  def handle_call({:collisions}, _from, state) do
    %{all: all}=new_state = all_impl(state)
    collisions = all |> Enum.group_by(&ExampleFiles.File.path_when_pulled/1)
                     |> Map.values
                     |> Enum.filter(&(1 < length(&1)))

    {:reply, collisions, new_state}
  end

  def handle_call({:noncollisions}, _from, state) do
    %{all: all}=new_state = all_impl(state)
    noncollisions = all |> Enum.group_by(&ExampleFiles.File.path_when_pulled/1)
                        |> Map.values
                        |> Enum.filter_map(&(length(&1) == 1),
                                           &(&1 |> List.first))

    {:reply, noncollisions, new_state}
  end

  @spec interesting?(binary, GenServer.server) :: boolean
  defp interesting?(path, options) do
    ignore     = options |> Options.ignore
    is_verbose = options |> Options.verbose?
    if String.starts_with?(path, ignore) do
      if is_verbose do
        list = ignore |> Enum.map(&(&1 |> UI.underline
                                       |> ANSI.format_fragment
                                       |> IO.chardata_to_string))
                      |> English.list("or")
        UI |> UI.info(["Ignoring ",
                       UI.underline(path),
                       " because it matches ignored path ",
                       list])
      end
      false
    else
      if File.dir?(path) do
        if is_verbose do
          UI |> UI.info(["Ignoring ",
                         UI.underline(path),
                         " because it is a directory"])
        end
        false
      else
        if ExampleFiles.File.example_file?(path) do
          true
        else
          if is_verbose do
            UI |> UI.info(["Ignoring ",
                           UI.underline(path),
                           " because it does not have the name of an example file"])
          end
          false
        end
      end
    end
  end

  @spec start_link_file_for(binary) :: pid
  defp start_link_file_for(path) do
    {:ok, file} = [path] |> ExampleFiles.File.start_link
    file
  end
end
