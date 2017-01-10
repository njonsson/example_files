defmodule ExampleFiles.Options do
  @moduledoc """
  A `GenServer` that provides access to program options.
  """

  use GenServer

  @typedoc "A set of program options."
  @type t :: t

  # TODO: Rename `:is_verbose` to `:verbose` and type it `:count` when targeting Elixir >= v1.3
  defstruct fileglobs:  [],
            ignore:     ~w(.git/ _build/ deps/ node_modules/ tmp/),
            is_quiet:   false,
            is_verbose: false

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

  @spec options(pid, timeout) :: t
  @doc """
  Returns the options in effect.

  ## Examples

      iex> {:ok, pid} = ExampleFiles.Options.start_link([])
      ...> pid |> ExampleFiles.Options.options
      %ExampleFiles.Options{fileglobs: ["**/*{example,Example,EXAMPLE}*"], ignore: ~w(.git/ _build/ deps/ node_modules/ tmp/), is_quiet: false, is_verbose: false}

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(foo bar* baz {qux,quux}))
      ...> pid |> ExampleFiles.Options.options
      %ExampleFiles.Options{fileglobs: ~w({foo,baz}/**/*{example,Example,EXAMPLE}* bar*/**/*{example,Example,EXAMPLE}* {qux,quux}/**/*{example,Example,EXAMPLE}*), ignore: ~w(.git/ _build/ deps/ node_modules/ tmp/), is_quiet: false, is_verbose: false}

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(foo --ignore bar -i baz qux))
      ...> pid |> ExampleFiles.Options.options
      %ExampleFiles.Options{fileglobs: ["{foo,qux}/**/*{example,Example,EXAMPLE}*"], ignore: ~w(bar baz), is_quiet: false, is_verbose: false}

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(--quiet --verbose))
      ...> pid |> ExampleFiles.Options.options
      %ExampleFiles.Options{fileglobs: ["**/*{example,Example,EXAMPLE}*"], ignore: ~w(.git/ _build/ deps/ node_modules/ tmp/), is_quiet: true, is_verbose: true}

      iex> {:ok, pid} = ExampleFiles.Options.start_link(~w(-q -v))
      ...> pid |> ExampleFiles.Options.options
      %ExampleFiles.Options{fileglobs: ["**/*{example,Example,EXAMPLE}*"], ignore: ~w(.git/ _build/ deps/ node_modules/ tmp/), is_quiet: true, is_verbose: true}
  """
  def options(options, timeout \\ 5000) do
    options |> GenServer.call({:options}, timeout)
  end

  # Server callbacks

  @spec init(any) :: {:ok, t} | {:stop, binary}
  def init([command_line_arguments]) when is_list(command_line_arguments) do
    case command_line_arguments |> parse_command_line do
      {parsed, arguments, []} ->
        fileglobs = arguments |> Fileglobs.parse
        ignore = parsed |> get_all_values([:ignore, :i])
        is_quiet = parsed[:quiet] || parsed[:q]
        is_verbose = parsed[:verbose] || parsed[:v]
        constructed = construct(fileglobs:  fileglobs,
                                ignore:     ignore,
                                is_quiet:   is_quiet,
                                is_verbose: is_verbose)
        {:ok, constructed}
      {_parsed, _arguments, unparsed} ->
        {:stop, "Unparsed arguments #{unparsed |> inspect}"}
    end
  end

  def init(_), do: {:stop, "Invalid command-line options"}

  def handle_call({:options}, _from, options), do: {:reply, options, options}

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
