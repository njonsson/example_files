defmodule ExampleFiles.English do
  @moduledoc false

  @spec list([binary]) :: binary
  @spec list([binary], binary) :: binary
  @doc """
  Joins English strings into a list.

  ## Examples

      iex> ["foo"] |> ExampleFiles.English.list
      "foo"

      iex> ~w(foo bar) |> ExampleFiles.English.list
      "foo and bar"

      iex> ~w(foo bar) |> ExampleFiles.English.list("or")
      "foo or bar"

      iex> ~w(foo bar baz) |> ExampleFiles.English.list
      "foo, bar, and baz"

      iex> ~w(foo bar baz) |> ExampleFiles.English.list("or")
      "foo, bar, or baz"

      iex> ~w(foo bar baz qux) |> ExampleFiles.English.list
      "foo, bar, baz, and qux"

      iex> ~w(foo bar baz qux) |> ExampleFiles.English.list("or")
      "foo, bar, baz, or qux"
  """

  def list(items, conjunction \\ "and")

  def list([item], _conjunction), do: item

  def list([_, _]=items, conjunction), do: items |> Enum.join(" #{conjunction} ")

  def list([item1, item2, item3], conjunction) do
    "#{item1}, #{item2}, #{conjunction} #{item3}"
  end

  def list([this | rest], conjunction) do
    [this, list(rest, conjunction)] |> Enum.join(", ")
  end

  @spec pluralize(integer, binary) :: binary
  @doc """
  Renders an English count-noun phrase.

  ## Examples

      iex> -1 |> ExampleFiles.English.pluralize("foo")
      "-1 foos"

      iex> -1 |> ExampleFiles.English.pluralize("ox", "oxen")
      "-1 oxen"

      iex> 0 |> ExampleFiles.English.pluralize("foo")
      "no foos"

      iex> 0 |> ExampleFiles.English.pluralize("ox", "oxen")
      "no oxen"

      iex> 1 |> ExampleFiles.English.pluralize("foo")
      "1 foo"

      iex> 1 |> ExampleFiles.English.pluralize("ox", "oxen")
      "1 ox"

      iex> 2 |> ExampleFiles.English.pluralize("foo")
      "2 foos"

      iex> 2 |> ExampleFiles.English.pluralize("ox", "oxen")
      "2 oxen"
  """
  def pluralize(count, singular), do: pluralize count, singular, "#{singular}s"

  @spec pluralize(integer, binary, binary) :: binary

  def pluralize(0, singular, plural), do: "no #{plural || "#{singular}s"}"

  def pluralize(1, singular, _plural), do: "1 #{singular}"

  def pluralize(count, singular, plural) do
    "#{count} #{plural || "#{singular}s"}"
  end
end
