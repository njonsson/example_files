defmodule ExampleFiles.File do
  @moduledoc """
  A `GenServer` that provides access to a project file that serves as an example
  or a template for a project file.

  The state of an `ExampleFiles.File` process is its filesystem path.
  """

  use GenServer

  @typedoc """
  An error encountered while processing an example file.

  To transform the second term of the tuple into user-friendly form, pass it to
  [`:file.format_error/1`](http://erlang.org/doc/man/file.html#format_error-1).
  """
  @type error :: {:error, :eacces | :eperm | :enotdir}

  @typedoc "The status of an example file."
  @type status :: :missing | :identical | :out_of_date

  @basename_as_delimited_left_regex   ~r/(\.|_|-)example(\.|_|-|$)/i
  @basename_as_delimited_right_regex  ~r/(^|\.|_|-)example(\.|_|-)/i
  @basename_as_camelcase_start_regex  ~r/^[Ee]xample([[:upper:]]|\d|$)/
  @basename_as_camelcase_middle_regex ~r/([[:lower:]]|\d)Example([[:upper:]]|\d|$)/

  # Client API

  # TODO: Update this spec using the new `keyword` type under Elixir v1.3
  # @spec start_link(binary | [binary], keyword) :: GenServer.on_start
  @spec start_link(binary | [binary], [{atom, any}]) :: GenServer.on_start
  @doc """
  Starts an `ExampleFiles.File` process, linked to the current process, with the
  specified `path`.

  The process exits if `path` is not an example file (see `example_file?/1`).
  """

  def start_link(arguments, options \\ [])

  def start_link(arguments, options) when is_list(arguments) do
    __MODULE__ |> GenServer.start_link(arguments, options)
  end

  def start_link(path, options), do: [path] |> start_link(options)

  @spec clean(pid, timeout) :: {:ok, :deleted | :enoent} | error
  @doc """
  Deletes the file at the example file’s path-when-pulled (see
  `path_when_pulled/1`).

  ## Examples

      iex> path = Path.join(System.tmp_dir!, String.slice(to_string(:rand.uniform), 2..-1)) <> ".example"
      ...> {:ok, file} = ExampleFiles.File.start_link([path])
      ...> false = file |> ExampleFiles.File.path_when_pulled |> File.exists?
      ...> {:ok, :enoent} = file |> ExampleFiles.File.clean
      ...> file |> ExampleFiles.File.path_when_pulled |> File.exists?
      false

      iex> path = Path.join(System.tmp_dir!, String.slice(to_string(:rand.uniform), 2..-1)) <> ".example"
      ...> {:ok, file} = ExampleFiles.File.start_link([path])
      ...> file |> ExampleFiles.File.path_when_pulled |> File.touch!
      ...> true = file |> ExampleFiles.File.path_when_pulled |> File.exists?
      ...> {:ok, :deleted} = file |> ExampleFiles.File.clean
      ...> file |> ExampleFiles.File.path_when_pulled |> File.exists?
      false
  """
  def clean(file, timeout \\ 5000), do: file |> GenServer.call({:clean}, timeout)

  @spec example_file?(binary) :: boolean
  @doc """
  Returns `true` if the specified `path` qualifies as an example file.

  ## Examples

      iex> "foo" |> ExampleFiles.File.example_file?
      false

      iex> "example" |> ExampleFiles.File.example_file?
      false

      iex> "fooexample" |> ExampleFiles.File.example_file?
      false

      iex> "examplefoo" |> ExampleFiles.File.example_file?
      false

      iex> "foo.example/bar" |> ExampleFiles.File.example_file?
      false

      iex> "foo.example" |> ExampleFiles.File.example_file?
      true

      iex> "foo/bar-example" |> ExampleFiles.File.example_file?
      true

      iex> "fooExample" |> ExampleFiles.File.example_file?
      true

      iex> "example_foo" |> ExampleFiles.File.example_file?
      true

      iex> "exampleFoo" |> ExampleFiles.File.example_file?
      true

      iex> "foo.Example" |> ExampleFiles.File.example_file?
      true

      iex> "Example.foo" |> ExampleFiles.File.example_file?
      true

      iex> "123Example" |> ExampleFiles.File.example_file?
      true

      iex> "Example123" |> ExampleFiles.File.example_file?
      true

      iex> "foo.EXAMPLE" |> ExampleFiles.File.example_file?
      true

      iex> "EXAMPLE.foo" |> ExampleFiles.File.example_file?
      true

      iex> "foo.example.bar" |> ExampleFiles.File.example_file?
      true

      iex> "fooExampleBar" |> ExampleFiles.File.example_file?
      true

      iex> "123Example456" |> ExampleFiles.File.example_file?
      true
  """
  def example_file?(path) do
    basename = path |> Path.basename
    !String.match?(basename, ~r/^example$/i) &&
      (String.match?(basename, @basename_as_delimited_left_regex)  ||
       String.match?(basename, @basename_as_delimited_right_regex) ||
       String.match?(basename, @basename_as_camelcase_start_regex) ||
       String.match?(basename, @basename_as_camelcase_middle_regex))
  end

  @spec path(pid, timeout) :: binary
  @doc """
  Returns the example file’s path.

  ## Examples

      iex> {:ok, file} = ExampleFiles.File.start_link("foo.example")
      ...> file |> ExampleFiles.File.path
      "foo.example"
  """
  def path(file, timeout \\ 5000), do: file |> GenServer.call({:path}, timeout)

  @spec path_when_pulled(pid, timeout) :: binary
  @doc """
  Computes the path of the example file when it is pulled (see `pull/1`).

  ## Examples

      iex> {:ok, file} = ExampleFiles.File.start_link("foo.example")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("foo/bar-example")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo/bar"

      iex> {:ok, file} = ExampleFiles.File.start_link("fooExample")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("example_foo")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("exampleFoo")
      ...> file |> ExampleFiles.File.path_when_pulled
      "Foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("foo.Example")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("Example.foo")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("123Example")
      ...> file |> ExampleFiles.File.path_when_pulled
      "123"

      iex> {:ok, file} = ExampleFiles.File.start_link("Example123")
      ...> file |> ExampleFiles.File.path_when_pulled
      "123"

      iex> {:ok, file} = ExampleFiles.File.start_link("foo.EXAMPLE")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("EXAMPLE.foo")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo"

      iex> {:ok, file} = ExampleFiles.File.start_link("foo.example.bar")
      ...> file |> ExampleFiles.File.path_when_pulled
      "foo.bar"

      iex> {:ok, file} = ExampleFiles.File.start_link("fooExampleBar")
      ...> file |> ExampleFiles.File.path_when_pulled
      "fooBar"

      iex> {:ok, file} = ExampleFiles.File.start_link("123Example456")
      ...> file |> ExampleFiles.File.path_when_pulled
      "123456"
  """
  def path_when_pulled(file, timeout \\ 5000) do
    file |> GenServer.call({:path_when_pulled}, timeout)
  end

  @spec pull(pid, timeout) :: {:ok, :copied | :identical} | error
  @doc """
  Copies the example file to its path-when-pulled (see `path_when_pulled/1`).
  """
  def pull(file, timeout \\ 5000), do: file |> GenServer.call({:pull}, timeout)

  @spec status(pid, timeout) :: status
  @doc """
  Computes the status of the example file.

  ## Examples

      iex> path = Path.join(System.tmp_dir!, String.slice(to_string(:rand.uniform), 2..-1)) <> ".example"
      ...> {:ok, file} = ExampleFiles.File.start_link([path])
      ...> file |> ExampleFiles.File.status
      :missing
  """
  def status(file, timeout \\ 5000) do
    file |> GenServer.call({:status}, timeout)
  end

  @spec identical?(binary, binary) :: boolean
  defp identical?(path1, path2) do
    case File.read(path1) do
      {:ok, content1} ->
        case File.read(path2) do
          {:ok, content2}   -> content1 == content2
          {:error, :enoent} -> false
          {:error, reason}  -> reason |> :file.format_error |> raise
        end
      {:error, :enoent} ->
        ! File.exists?(path2)
      {:error, reason} ->
        reason |> :file.format_error |> raise
    end
  end

  @spec pulled(binary) :: binary
  defp pulled(path) do
    basename = Path.basename(path)

    pulled_basename = basename |> String.replace(@basename_as_delimited_left_regex,   "\\2")
                               |> String.replace(@basename_as_delimited_right_regex,  "\\1")
                               |> String.replace(@basename_as_camelcase_start_regex,  "\\1")
                               |> String.replace(@basename_as_camelcase_middle_regex, "\\1\\2")

    if (dirname = Path.dirname(path)) == "." do
      pulled_basename
    else
      Path.join dirname, pulled_basename
    end
  end

  # Server callbacks

  def init([path]) when is_binary(path) do
    if path |> example_file? do
      {:ok, path}
    else
      init false
    end
  end

  def init(_), do: {:stop, "Not an example file"}

  def handle_call({:clean}, _from, path) do
    path_when_pulled = path |> pulled
    result = case path_when_pulled |> File.rm do
      :ok               -> {:ok, :deleted}
      {:error, :enoent} -> {:ok, :enoent}
      other             -> other
    end
    {:reply, result, path}
  end

  def handle_call({:path}, _from, path), do: {:reply, path, path}

  def handle_call({:path_when_pulled}, _from, path) do
    path_when_pulled = path |> pulled
    {:reply, path_when_pulled, path}
  end

  def handle_call({:pull}, _from, path) do
    path_when_pulled = path |> pulled
    result = if File.exists?(path) && identical?(path, path_when_pulled) do
               {:ok, :identical}
             else
               case path |> File.cp(path_when_pulled) do
                 :ok   -> {:ok, :copied}
                 other -> other
               end
             end
    {:reply, result, path}
  end

  def handle_call({:status}, _from, path) do
    path_when_pulled = path |> pulled
    status = if File.exists?(path) && File.exists?(path_when_pulled) do
               if identical?(path, path_when_pulled) do
                 :identical
               else
                 :out_of_date
               end
             else
               :missing
             end
    {:reply, status, path}
  end
end
