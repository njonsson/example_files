defmodule ExampleFiles.Fileglobs do
  @moduledoc """
  Converts filespecs into example-file fileglobs.
  """

  @spec parse([binary]) :: [binary]
  @doc """
  Converts the specified filespec or `List` of zero or more filespecs into a
  `List` of one or more fileglob expressions. The resultant fileglob
  expressions are suitable for finding example files with `Path.wildcard/1`.

  ## Examples

      iex> [] |> ExampleFiles.Fileglobs.parse
      ["**/*{example,Example,EXAMPLE}*"]

      iex> ["foo"] |> ExampleFiles.Fileglobs.parse
      ["foo/**/*{example,Example,EXAMPLE}*"]

      iex> ~w(foo bar) |> ExampleFiles.Fileglobs.parse
      ["{foo,bar}/**/*{example,Example,EXAMPLE}*"]

      iex> ~w(foo* ba?) |> ExampleFiles.Fileglobs.parse
      ~w(foo*/**/*{example,Example,EXAMPLE}* ba?/**/*{example,Example,EXAMPLE}*)

      iex> ~w(foo bar* baz qu*x) |> ExampleFiles.Fileglobs.parse
      ~w({foo,baz}/**/*{example,Example,EXAMPLE}* bar*/**/*{example,Example,EXAMPLE}* qu*x/**/*{example,Example,EXAMPLE}*)

      iex> ~w(foo {bar,baz} qux qu?x) |> ExampleFiles.Fileglobs.parse
      ~w({foo,qux}/**/*{example,Example,EXAMPLE}* {bar,baz}/**/*{example,Example,EXAMPLE}* qu?x/**/*{example,Example,EXAMPLE}*)

      iex> ~w(foo ba[rz] qux qu?x) |> ExampleFiles.Fileglobs.parse
      ~w({foo,qux}/**/*{example,Example,EXAMPLE}* ba[rz]/**/*{example,Example,EXAMPLE}* qu?x/**/*{example,Example,EXAMPLE}*)
  """

  def parse([]), do: "" |> append_example |> List.wrap

  def parse([filespec]), do: filespec |> append_example |> List.wrap

  def parse(filespecs) do
    categorized = filespecs |> Enum.reduce([], fn(filespec, acc) ->
      is_wildcard_or_nested = wildcard?(filespec) || nested?(filespec)
      category = if is_wildcard_or_nested, do: :uncombinables, else: :combinables
      acc |> Keyword.update(category,
                            [filespec],
                            &(&1 |> List.insert_at(-1, filespec)))
    end)
    combined = categorized |> Enum.reduce([], fn({category, filespecs}, acc) ->
      case category do
        :uncombinables -> acc ++ filespecs
        :combinables   -> acc |> List.insert_at(-1, combine(filespecs))
      end
    end)
    combined |> Enum.map(&append_example/1)
  end

  @spec append_example(binary) :: binary
  defp append_example(filespec) do
    filespec |> Path.join("**/*{example,Example,EXAMPLE}*")
  end

  @spec combine([binary]) :: binary
  defp combine(filespecs), do: "{#{filespecs |> Enum.join(",")}}"

  @spec nested?(binary) :: boolean
  defp nested?(filespec) do
    if filespec |> String.starts_with?("/") do
      true
    else
      # TODO: Use String.trim_trailing/1 when targeting Elixir >= v1.3
      filespec |> String.replace(~r(/+$), "") |> String.contains?("/")
    end
  end

  @spec wildcard?(binary) :: boolean
  defp wildcard?(filespec), do: filespec |> String.contains?(~w(* ? { } [ ]))
end
