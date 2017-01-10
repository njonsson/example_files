defmodule ExampleFiles.UI do
  @moduledoc """
  Provides functions for stdout/stderr output and ANSI escape-sequence
  formatting.
  """

  use GenServer

  alias IO.ANSI

  for {format, unformat} <- [blue:      :default_color,
                             green:     :default_color,
                             red:       :default_color,
                             yellow:    :default_color,
                             underline: :no_underline] do
    description = if format == :underline do
                    "underlining"
                  else
                    "its foreground in #{format}"
                  end
    @spec unquote(format)(ANSI.ansidata) :: ANSI.ansidata
    @doc """
    Formats `ansi_data` with #{description}.
    """
    def unquote(format)(ansi_data) do
      [unquote(format), ansi_data, unquote(unformat)]
    end
  end

  @typedoc "A UI display stream."
  @type stream :: :error | :info

  # Client API

  # TODO: Update this spec using the new `keyword` type under Elixir v1.3
  # @spec start_link([autoflush: boolean], keyword) :: GenServer.on_start
  @spec start_link([autoflush: boolean], [{atom, any}]) :: GenServer.on_start
  @doc """
  Starts an `ExampleFiles.UI` process, linked to the current process, with the
  specified `autoflush` option.
  """
  def start_link(arguments \\ [], options \\ []) do
    arguments = arguments |> Keyword.put_new(:autoflush, true)
    __MODULE__ |> GenServer.start_link(arguments, options)
  end

  @spec autoflush(GenServer.server, boolean, timeout) :: boolean
  @doc """
  Determines if the UI process automatically displays content provided to
  `info/2` and `error/2`. Inspect this property, without changing its value,
  using `autoflush?/2`.

  ## Examples

      iex> {:ok, ui} = ExampleFiles.UI.start_link
      ...> ui |> ExampleFiles.UI.autoflush(false)
      ...> ui |> ExampleFiles.UI.autoflush?
      false
  """
  def autoflush(ui, value, timeout \\ 5000) do
    ui |> GenServer.call({:autoflush, value}, timeout)
  end

  @spec autoflush?(GenServer.server, timeout) :: boolean
  @doc """
  Returns `true` if the UI process automatically displays content provided to
  `info/2` and `error/2`. Change this property using `autoflush/3`.

  ## Examples

      iex> {:ok, ui} = ExampleFiles.UI.start_link
      ...> ui |> ExampleFiles.UI.autoflush?
      true
  """
  def autoflush?(ui, timeout \\ 5000) do
    ui |> GenServer.call({:autoflush?}, timeout)
  end

  @spec flush(GenServer.server, timeout) :: [{stream, binary}]
  def flush(ui, timeout \\ 5000), do: ui |> GenServer.call({:flush}, timeout)

  @streams [error: :stderr, info: :stdout]

  for {stream, name} <- @streams do
    @spec unquote(stream)(GenServer.server, ANSI.ansidata, timeout) :: binary
    @doc """
    Prints `ansi_data` to the #{name} stream, or appends it to the cache if
    `autoflush?/2` is `false`. Returns the string printed, or `nil`.
    """
    def unquote(stream)(ui, ansi_data \\ "", timeout \\ 5000) do
      ui |> GenServer.call({unquote(stream), ansi_data}, timeout)
    end

    stream_insert_at = "#{stream}_insert_at" |> String.to_atom

    @spec unquote(stream_insert_at)(GenServer.server, integer, ANSI.ansidata, timeout) :: binary
    @doc """
    Prints `ansi_data` to the #{name} stream, or inserts it in the cache at the
    specified location if `autoflush?/2` is `false`. Returns the string printed,
    or `nil`.
    """
    def unquote(stream_insert_at)(ui, index, ansi_data \\ "", timeout \\ 5000) do
      ui |> GenServer.call({unquote(stream_insert_at), index, ansi_data},
                           timeout)
    end
  end

  @spec flush_impl([{stream, ANSI.ansidata}]) :: [{stream, binary}]

  defp flush_impl([]), do: []

  defp flush_impl([{stream, ansi_data} | rest_of_cache_stack]) do
    ansi_formatted = [ANSI.reset, ansi_data] |> ANSI.format_fragment
                                             |> IO.chardata_to_string
    Mix.shell |> apply(stream, [ansi_formatted])
    [{stream, ansi_formatted} | flush_impl(rest_of_cache_stack)]
  end

  # TODO: Update this spec using the new `keyword` type under Elixir v1.3
  # @spec insert_at(keyword, stream, integer, ANSI.ansidata) :: {binary | nil, keyword}
  @spec insert_at([{atom, any}], stream, integer, ANSI.ansidata) :: {binary | nil, [{atom, any}]}
  defp insert_at(state, stream, index, ansi_data) do
    new_cache = state[:cache] |> List.wrap
                              |> List.insert_at((-index - 1),
                                                {stream, ansi_data})
    if state[:autoflush] do
      result = new_cache |> flush_impl
      {result, state |> Keyword.put(:cache, [])}
    else
      {nil, state |> Keyword.put(:cache, new_cache)}
    end
  end

  # Server callbacks

  def handle_call({:autoflush, value}, _from, state) do
    {result, new_state} = if value do
                            result = state[:cache] |> List.wrap |> flush_impl
                            {result, state |> Keyword.put(:cache, [])}
                          else
                            {value, state}
                          end
    {:reply, result, new_state |> Keyword.put(:autoflush, value)}
  end

  def handle_call({:autoflush?}, _from, state) do
    {:reply, state[:autoflush], state}
  end

  def handle_call({:flush}, _from, state) do
    flushed = state[:cache] |> List.wrap |> flush_impl
    new_state = state |> Keyword.delete(:cache)
    {:reply, flushed, new_state}
  end

  for {stream, _} <- @streams do
    stream_insert_at = "#{stream}_insert_at" |> String.to_atom

    def handle_call({unquote(stream), ansi_data}, _from, state) do
      {result, new_state} = state |> insert_at(unquote(stream), 0, ansi_data)
      {:reply, result, new_state}
    end

    def handle_call({unquote(stream_insert_at), index, ansi_data},
                    _from,
                    state) do
      {result, new_state} = state |> insert_at(unquote(stream),
                                               (-index - 1),
                                               ansi_data)
      {:reply, result, new_state}
    end
  end
end
