defmodule ExampleFiles.Options do
  @moduledoc """
  A `GenServer` that provides access to program options.
  """

  use GenServer

  @typedoc false
  @type t :: t

  # TODO: Rename `:verbose?` to `:verbose` and type it `:count` when targeting Elixir >= v1.3
  defstruct fileglobs:  [],
            ignore:     ~w(.git/ _build/ deps/ node_modules/ tmp/),
            quiet?:     false,
            verbose?:   false

  alias ExampleFiles.Fileglobs

  # Client API

  # TODO: Update this spec using the new `keyword` type under Elixir v1.3
  # @spec start_link(binary | [binary], keyword) :: GenServer.on_start
  @spec start_link([binary] | [[binary]], [{atom, any}]) :: GenServer.on_start
  @doc """
  Starts an `ExampleFiles.Options` process, linked to the current process, with
  the specified `command_line_arguments`.

  The process exits if `command_line_arguments` is not a list of valid
  command-line arguments.
  """
  def start_link(arguments, options \\ [])

  def start_link([command_line_arguments],
                 options) when is_list(command_line_arguments) do
    __MODULE__ |> GenServer.start_link([command_line_arguments], options)
  end

  def start_link(command_line_arguments,
                 options) when is_list(command_line_arguments) do
    [command_line_arguments] |> start_link(options)
  end

  @spec fileglobs(pid, timeout) :: [binary]
  @doc """
  Returns the fileglob options in effect.

  ## Examples

      iex> {:ok, pid} = ExampleFiles.Options.start_link([])
      ...> pid |> ExampleFiles.Options.fileglobs
      ["**/*{example,Example,EXAMPLE}*"]

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(foo bar* baz {qux,quux}))
      ...> pid |> ExampleFiles.Options.fileglobs
      ~w({foo,baz}/**/*{example,Example,EXAMPLE}* bar*/**/*{example,Example,EXAMPLE}* {qux,quux}/**/*{example,Example,EXAMPLE}*)
  """
  def fileglobs(options, timeout \\ 5000) do
    options |> GenServer.call({:fileglobs}, timeout)
  end

  @spec ignore(pid, timeout) :: [binary]
  @doc """
  Returns the ignored-path options in effect.

  ## Examples

      iex> {:ok, pid} = ExampleFiles.Options.start_link([])
      ...> pid |> ExampleFiles.Options.ignore
      ~w(.git/ _build/ deps/ node_modules/ tmp/)

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(--ignore foo -i bar baz))
      ...> pid |> ExampleFiles.Options.ignore
      ~w(foo bar)
  """
  def ignore(options, timeout \\ 5000) do
    options |> GenServer.call({:ignore}, timeout)
  end

  @spec quiet?(pid, timeout) :: boolean
  @doc """
  Returns the quiet option in effect.

  ## Examples

      iex> {:ok, pid} = ExampleFiles.Options.start_link([])
      ...> pid |> ExampleFiles.Options.quiet?
      false

      iex> {:ok, pid} = ExampleFiles.Options.start_link(["--quiet"])
      ...> pid |> ExampleFiles.Options.quiet?
      true

      iex> {:ok, pid} = ExampleFiles.Options.start_link(["-q"])
      ...> pid |> ExampleFiles.Options.quiet?
      true
  """
  def quiet?(options, timeout \\ 5000) do
    options |> GenServer.call({:quiet?}, timeout)
  end

  @spec verbose?(pid, timeout) :: boolean
  @doc """
  Returns the verbosity option in effect.

  ## Examples

      iex> {:ok, pid} = ExampleFiles.Options.start_link([])
      ...> pid |> ExampleFiles.Options.verbose?
      false

      iex> {:ok, pid} = ExampleFiles.Options.start_link(["--verbose"])
      ...> pid |> ExampleFiles.Options.verbose?
      true

      iex> {:ok, pid} = ExampleFiles.Options.start_link(["-v"])
      ...> pid |> ExampleFiles.Options.verbose?
      true
  """
  def verbose?(options, timeout \\ 5000) do
    options |> GenServer.call({:verbose?}, timeout)
  end

  # Server callbacks

  def init([command_line_arguments]) when is_list(command_line_arguments) do
    case command_line_arguments |> parse_command_line do
      {parsed, arguments, []} ->
        fileglobs = arguments |> Fileglobs.parse
        ignore = parsed |> get_all_values([:ignore, :i])
        is_quiet = parsed[:quiet] || parsed[:q]
        is_verbose = parsed[:verbose] || parsed[:v]
        constructed = construct(fileglobs: fileglobs,
                                ignore:    ignore,
                                quiet?:    is_quiet,
                                verbose?:  is_verbose)
        {:ok, constructed}
      {_parsed, _arguments, unparsed} ->
        clean_unparsed = unparsed |> Enum.map(fn({unparsed_item, nil}) ->
                                                   unparsed_item
                                                 other ->
                                                   other
                                              end)
        {:stop, "Unparsed arguments #{clean_unparsed |> inspect}"}
    end
  end

  def init(_), do: {:stop, "Invalid command-line options"}

  for option <- ~w(fileglobs ignore quiet? verbose?)a do
    def handle_call({unquote(option)}, _from, state) do
      option_value = state |> Map.fetch!(unquote(option))
      {:reply, option_value, state}
    end
  end

  @spec construct(Keyword.t) :: t
  defp construct(attributes) do
    present_attributes = attributes |> Enum.reject(fn({_, v}) -> v |> is_nil end)
    __MODULE__ |> struct(present_attributes)
  end

  @spec get_all_values(Keyword.t, [Keyword.key]) :: [Keyword.value]
  defp get_all_values(keywords, keys) do
    values = keywords |> Keyword.take(keys) |> Keyword.values
    if length(values) == 0, do: nil, else: values
  end

  @spec parse_command_line([binary]) :: {Keyword.t, [binary], [tuple]}
  defp parse_command_line(command_line_arguments) do
    command_line_arguments |> OptionParser.parse(strict: [ignore:  :keep,
                                                          quiet:   :boolean,
                                                          verbose: :boolean],
                                                 aliases: [i: :ignore,
                                                           q: :quiet,
                                                           v: :verbose])
  end
end
